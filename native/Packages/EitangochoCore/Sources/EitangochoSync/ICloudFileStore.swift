import Foundation

/// iCloud Drive のアプリコンテナに置いた同期用 JSON を 1 個だけ読み書きする。
///
/// Flutter 版の shared/IcloudFileStorePlugin.swift から Flutter への依存を外して移したもの。
/// コンテナ・ファイル名・最新化を待つ手順・競合版の扱いは Flutter 版と同じにする
/// (移行期間は両方の版が同じファイルを読み書きするため。直すときは両方を直す)。
///
/// icloud_storage 系の外部ライブラリを使わないのは、要る操作が
/// 「コンテナ URL の取得 / 1 ファイルの読み書き / 更新日時 / 競合版の扱い」だけで、
/// 外部への依存を増やすより自前で持つ方が小さいため。
public final class ICloudFileStore: CloudFileStore, @unchecked Sendable {
  /// コンテナ内のファイル名。Info.plist で NSUbiquitousContainers を公開していないため、
  /// Documents の下でも「ファイル」アプリや Finder には出ない。
  static let fileName = "eitangocho-sync.json"

  /// ファイル操作を回すキュー。ubiquity container の解決も含めて主スレッドを
  /// 止めうるため、すべてここで行う。`pendingConflicts` もこのキューの上でだけ触る
  /// (`@unchecked Sendable` はこの約束による)。
  private let queue = DispatchQueue(label: "eitangocho.icloud", qos: .userInitiated)

  /// 端末のコピーが最新版になるのを待つ上限と、状態を見直す間隔。
  /// 待つのはこのキューの上なので主スレッドは止まらない。
  private static let downloadTimeout: TimeInterval = 15
  private static let pollInterval: TimeInterval = 0.5

  /// readConflicts で渡した競合版。resolveConflicts が id から引く。
  private var pendingConflicts: [String: NSFileVersion] = [:]

  public init() {}

  public func read() async throws -> String? {
    try await perform { url in
      // NSFileCoordinator の読み取りは、端末に古いコピーがあるとダウンロードの完了を
      // 待たずにそれを返す。古い内容を読んで書き戻すと他端末の新しい版を競合版に
      // 追いやってしまうため、最新になるまで待ち、待ちきれなければ読まずに見送る。
      guard Self.waitUntilCurrent(url) else { throw CloudError.notCurrent }

      var coordinatorError: NSError?
      var result: Result<String?, Error> = .success(nil)
      NSFileCoordinator().coordinate(readingItemAt: url, options: [], error: &coordinatorError) { readURL in
        guard FileManager.default.fileExists(atPath: readURL.path) else { return }
        result = Result { try String(contentsOf: readURL, encoding: .utf8) }
      }
      if let coordinatorError { throw Self.failure(coordinatorError) }
      return try result.mapError(Self.failure).get()
    }
  }

  public func write(_ contents: String) async throws {
    try await perform { url in
      // 読んでから書くまでの間に他端末の新しい版が届き始めていたら、書かずに見送る
      // (read の待ちと同じ理由。ここで書くとその版が競合版になる)。
      guard Self.isCurrent(url) else { throw CloudError.notCurrent }

      var coordinatorError: NSError?
      var writeError: Error?
      NSFileCoordinator().coordinate(writingItemAt: url, options: .forReplacing, error: &coordinatorError) {
        writeURL in
        do {
          try contents.write(to: writeURL, atomically: true, encoding: .utf8)
        } catch {
          writeError = error
        }
      }
      if let error = coordinatorError ?? writeError { throw Self.failure(error) }
    }
  }

  public func lastModified() async throws -> Date? {
    try await perform { url in
      var coordinatorError: NSError?
      var date: Date?
      NSFileCoordinator().coordinate(readingItemAt: url, options: .withoutChanges, error: &coordinatorError) {
        readURL in
        date = try? readURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
      }
      // ファイルが無いときは coordinator がエラーを返すが、異常ではなく
      // 「まだ同期ファイルが作られていない」だけなので nil を返す。
      return date
    }
  }

  public func readConflicts() async throws -> [CloudConflict] {
    try await perform { url in
      // 同期のたびに読み直すので、前回渡した分は捨てる。
      self.pendingConflicts = [:]
      var items: [CloudConflict] = []
      for version in NSFileVersion.unresolvedConflictVersionsOfItem(at: url) ?? [] {
        // 読めない版は渡さない(片付けられずに残り、次の同期で読み直される)。
        guard let contents = try? String(contentsOf: version.url, encoding: .utf8) else { continue }
        let id = UUID().uuidString
        self.pendingConflicts[id] = version
        items.append(CloudConflict(id: id, contents: contents, modifiedAt: version.modificationDate))
      }
      return items
    }
  }

  /// NSFileVersion.removeOtherVersionsOfItem を使わないのは、読み取り後に届いた
  /// (まだ取り込んでいない)競合版まで消してしまうため。
  public func resolveConflicts(_ ids: [String]) async throws {
    try await perform { url in
      let versions = ids.compactMap { self.pendingConflicts.removeValue(forKey: $0) }
      guard !versions.isEmpty else { return }

      var coordinatorError: NSError?
      var removeError: Error?
      NSFileCoordinator().coordinate(writingItemAt: url, options: [], error: &coordinatorError) { _ in
        for version in versions {
          version.isResolved = true
          do {
            try version.remove()
          } catch {
            removeError = error
          }
        }
      }
      if let error = coordinatorError ?? removeError { throw Self.failure(error) }
    }
  }

  // MARK: - 下回り

  /// キューの上で同期ファイルの URL を解決してから `body` を実行する。
  private func perform<T: Sendable>(_ body: @escaping @Sendable (URL) throws -> T) async throws -> T {
    try await withCheckedThrowingContinuation { continuation in
      queue.async {
        guard let url = Self.syncFileURL() else {
          continuation.resume(throwing: CloudError(.noICloud))
          return
        }
        continuation.resume(with: Result { try body(url) })
      }
    }
  }

  /// 同期ファイルの URL。iCloud が使えなければ nil。
  ///
  /// コンテナ ID に nil を渡すと entitlements の先頭のコンテナが選ばれる。
  /// Debug ビルドは Bundle ID と同じ .dev 付きのコンテナを entitlements に
  /// 書いているので、これだけで本番と開発が分かれる。
  private static func syncFileURL() -> URL? {
    guard let container = FileManager.default.url(forUbiquityContainerIdentifier: nil) else { return nil }
    let documents = container.appendingPathComponent("Documents", isDirectory: true)
    // 初回は Documents が無いので作っておく(あれば何もしない)。
    try? FileManager.default.createDirectory(at: documents, withIntermediateDirectories: true)
    return documents.appendingPathComponent(fileName)
  }

  /// 端末のコピーがクラウドの最新版か。
  ///
  /// 状態を取れないのは、クラウドにまだ同期ファイルが無いとき。古いコピーを
  /// 掴む恐れは無いので最新として扱う(初回の同期でファイルを作れるように)。
  private static func isCurrent(_ url: URL) -> Bool {
    // URL は属性をキャッシュするため、取り直して最新の値を見る。
    var freshURL = url
    freshURL.removeAllCachedResourceValues()
    guard
      let status = try? freshURL.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
        .ubiquitousItemDownloadingStatus
    else { return true }
    return status == .current
  }

  /// 端末のコピーが最新版になるまで待つ。上限までに最新にならなければ false。
  private static func waitUntilCurrent(_ url: URL) -> Bool {
    // 端末にコピーがあっても、これを呼ぶとクラウドの版とのすり合わせを急がせられる。
    // 呼ばずに OS 任せにすると、数分たってもダウンロードが終わらないことがあった。
    try? FileManager.default.startDownloadingUbiquitousItem(at: url)
    let deadline = Date().addingTimeInterval(downloadTimeout)
    while !isCurrent(url) {
      guard Date() < deadline else { return false }
      Thread.sleep(forTimeInterval: pollInterval)
    }
    return true
  }

  /// 読み書きの失敗。OS が端末の言語で返す説明を補足として残す。
  private static func failure(_ error: Error) -> CloudError {
    if let error = error as? CloudError { return error }
    return CloudError(.failed, detail: (error as NSError).localizedDescription)
  }
}
