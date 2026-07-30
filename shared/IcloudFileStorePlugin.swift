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

  /// コンテナ内のファイル名。Documents 配下に置くと iCloud Drive の
  /// アプリフォルダとしてユーザーからも見える。
  private static let fileName = "eitangocho-sync.json"

  /// ファイル操作を回すキュー。ubiquity container の解決も含めて
  /// 主スレッドをブロックしうるため、すべてここで実行する。
  private let queue = DispatchQueue(label: "eitangocho.icloud", qos: .userInitiated)

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
    // まだローカルに実体が無い(クラウドにしかない)場合があるため、
    // ダウンロードを促してから読む。
    if !FileManager.default.fileExists(atPath: url.path) {
      try? FileManager.default.startDownloadingUbiquitousItem(at: url)
      // ダウンロード待ちは NSFileCoordinator の読み取りが面倒を見る。
      // それでも実体が現れない場合は「未作成」として nil を返す。
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
}
