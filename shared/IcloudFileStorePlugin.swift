// iCloud Drive のアプリコンテナに置いた同期用 JSON を 1 個だけ読み書きする。
//
// macOS / iOS で同じ実装を使うため、このファイルは shared/ に置き、
// 両方の Xcode プロジェクトから参照している(片方だけ直す事故を防ぐため)。
//
// icloud_storage 系のパッケージを使わないのは、必要な操作が
// 「コンテナ URL の取得 / 1 ファイルの読み書き / 更新日時」の 3 つだけで、
// 更新の止まった外部依存を増やすより自前で持つ方が小さいと判断したため。

import Foundation

#if canImport(FlutterMacOS)
  import FlutterMacOS
#else
  import Flutter
#endif

public final class IcloudFileStorePlugin: NSObject {
  /// Dart 側(icloud_file_store.dart)と合わせる。
  private static let channelName = "eitangocho/icloud"

  /// コンテナ内のファイル名。Info.plist で NSUbiquitousContainers を公開していないため、
  /// Documents 配下でも「ファイル」アプリや Finder には表示されない。
  private static let fileName = "eitangocho-sync.json"

  /// ファイル操作を回すキュー。ubiquity container の解決も含めて
  /// 主スレッドをブロックしうるため、すべてここで実行する。
  private let queue = DispatchQueue(label: "eitangocho.icloud", qos: .userInitiated)

  /// 端末のコピーが最新版になるのを待つ上限と、状態を見直す間隔。
  /// 待つのはこのキューの上なので主スレッドは止まらない。
  private static let downloadTimeout: TimeInterval = 15
  private static let pollInterval: TimeInterval = 0.5

  public static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    let instance = IcloudFileStorePlugin()
    channel.setMethodCallHandler { call, result in
      instance.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    queue.async {
      let reply: (Any?) -> Void = { value in
        DispatchQueue.main.async { result(value) }
      }

      guard let url = self.syncFileURL() else {
        reply(
          FlutterError(
            code: "no-icloud",
            message: "iCloud が利用できません。設定で iCloud Drive にサインインしてください。",
            details: nil))
        return
      }

      switch call.method {
      case "read":
        self.read(url: url, reply: reply)
      case "write":
        guard let contents = (call.arguments as? [String: Any])?["contents"] as? String
        else {
          reply(
            FlutterError(code: "bad-args", message: "contents が渡されていません。", details: nil))
          return
        }
        self.write(contents: contents, url: url, reply: reply)
      case "lastModified":
        self.lastModified(url: url, reply: reply)
      default:
        reply(FlutterMethodNotImplemented)
      }
    }
  }

  /// 同期ファイルの URL。iCloud が使えない場合は nil。
  ///
  /// コンテナ ID に nil を渡すと entitlements の先頭のコンテナが選ばれる。
  /// Debug ビルドは Bundle ID と同じ .dev サフィックス付きコンテナを
  /// entitlements に書いているため、これだけで本番と開発が分かれる。
  private func syncFileURL() -> URL? {
    guard let container = FileManager.default.url(forUbiquityContainerIdentifier: nil)
    else { return nil }
    let documents = container.appendingPathComponent("Documents", isDirectory: true)
    // 初回は Documents が存在しないため作っておく(既にあれば何もしない)。
    try? FileManager.default.createDirectory(
      at: documents, withIntermediateDirectories: true)
    return documents.appendingPathComponent(Self.fileName)
  }

  private func read(url: URL, reply: @escaping (Any?) -> Void) {
    // NSFileCoordinator の読み取りは、端末に古いコピーがあるとダウンロードの完了を
    // 待たずにそれを返す。古い内容を読んで書き戻すと他端末の新しい版を競合版に
    // 追いやってしまうため、最新になるまで待ち、待ちきれなければ読まずに見送る。
    guard waitUntilCurrent(url) else {
      reply(Self.notCurrentError())
      return
    }

    var coordinatorError: NSError?
    var readError: Error?
    var contents: String?

    NSFileCoordinator().coordinate(
      readingItemAt: url, options: [], error: &coordinatorError
    ) { readURL in
      guard FileManager.default.fileExists(atPath: readURL.path) else { return }
      do {
        contents = try String(contentsOf: readURL, encoding: .utf8)
      } catch {
        readError = error
      }
    }

    if let error = coordinatorError ?? (readError as NSError?) {
      reply(
        FlutterError(
          code: "read-failed", message: error.localizedDescription, details: nil))
      return
    }
    reply(contents)
  }

  private func write(contents: String, url: URL, reply: @escaping (Any?) -> Void) {
    // 読んでから書くまでの間に他端末の新しい版が届き始めていたら、書かずに見送る
    // (read の待ちと同じ理由。ここで書くとその版が競合版になる)。
    guard isCurrent(url) else {
      reply(Self.notCurrentError())
      return
    }

    var coordinatorError: NSError?
    var writeError: Error?

    NSFileCoordinator().coordinate(
      writingItemAt: url, options: .forReplacing, error: &coordinatorError
    ) { writeURL in
      do {
        try contents.write(to: writeURL, atomically: true, encoding: .utf8)
      } catch {
        writeError = error
      }
    }

    if let error = coordinatorError ?? (writeError as NSError?) {
      reply(
        FlutterError(
          code: "write-failed", message: error.localizedDescription, details: nil))
      return
    }
    reply(nil)
  }

  private func lastModified(url: URL, reply: @escaping (Any?) -> Void) {
    var coordinatorError: NSError?
    var millis: Int?

    NSFileCoordinator().coordinate(
      readingItemAt: url, options: .withoutChanges, error: &coordinatorError
    ) { readURL in
      guard
        let values = try? readURL.resourceValues(forKeys: [.contentModificationDateKey]),
        let date = values.contentModificationDate
      else { return }
      millis = Int(date.timeIntervalSince1970 * 1000)
    }

    // ファイルが無いときは coordinator がエラーを返すが、それは異常ではなく
    // 「まだ同期ファイルが作られていない」だけなので nil を返す。
    if coordinatorError != nil && millis == nil {
      reply(nil)
      return
    }
    reply(millis)
  }

  /// 端末のコピーがクラウドの最新版か。
  ///
  /// 状態を取れないのは、クラウドにまだ同期ファイルが無いとき。古いコピーを
  /// 掴む恐れは無いので最新として扱う(初回の同期でファイルを作れるように)。
  private func isCurrent(_ url: URL) -> Bool {
    // URL は属性をキャッシュするため、取り直して最新の値を見る。
    var freshURL = url
    freshURL.removeAllCachedResourceValues()
    guard
      let status = try? freshURL.resourceValues(
        forKeys: [.ubiquitousItemDownloadingStatusKey]
      ).ubiquitousItemDownloadingStatus
    else { return true }
    return status == .current
  }

  /// 端末のコピーが最新版になるまで待つ。上限までに最新にならなければ false。
  private func waitUntilCurrent(_ url: URL) -> Bool {
    // 端末にコピーがあっても、これを呼ぶとクラウドの版とのすり合わせを急がせられる。
    // 呼ばずに OS 任せにすると、数分たってもダウンロードが終わらないことがあった。
    try? FileManager.default.startDownloadingUbiquitousItem(at: url)
    let deadline = Date().addingTimeInterval(Self.downloadTimeout)
    while !isCurrent(url) {
      guard Date() < deadline else { return false }
      Thread.sleep(forTimeInterval: Self.pollInterval)
    }
    return true
  }

  /// 最新化を待ちきれずに見送ったときのエラー。コードは Dart 側
  /// (icloud_file_store.dart)が再試行すべき失敗として見分けるのに使う。
  private static func notCurrentError() -> FlutterError {
    FlutterError(
      code: "not-current",
      message: "iCloud から最新のデータを取得できなかったため、同期を見送りました。",
      details: nil)
  }
}
