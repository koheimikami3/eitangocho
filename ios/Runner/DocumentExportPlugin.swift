// 単語帳 JSON の書き出し先をユーザーに選ばせる(iOS 専用)。
//
// file_selector_ios は openFile / openFiles しか実装しておらず、macOS 版で
// 使っている保存パネル(getSaveLocation)が存在しない。必要なのは
// 「一時ファイルを 1 個、選ばせた場所へコピーする」だけなので、
// IcloudFileStorePlugin と同じく自前の MethodChannel で最小限だけ用意する。

import Flutter
import UIKit

public final class DocumentExportPlugin: NSObject {
  /// Dart 側(document_exporter.dart)と合わせる。
  private static let channelName = "eitangocho/document_export"

  /// 表示中のピッカーのデリゲート。UIDocumentPickerViewController は delegate を
  /// 強参照しないため、ここで保持しないと選択前に解放されて応答が返らない。
  private var pendingDelegate: PickerDelegate?

  public static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    let instance = DocumentExportPlugin()
    channel.setMethodCallHandler { call, result in
      instance.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "export" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard
      let args = call.arguments as? [String: Any],
      let name = args["name"] as? String,
      let contents = args["contents"] as? String
    else {
      result(
        FlutterError(code: "bad-args", message: "name / contents が渡されていません。", details: nil))
      return
    }

    // ピッカーには URL しか渡せないため、一旦テンポラリに書き出す。
    // コピー後は不要なので、応答を返すときに消す。
    let source = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent(name)
    do {
      try contents.write(to: source, atomically: true, encoding: .utf8)
    } catch {
      result(
        FlutterError(code: "write-failed", message: error.localizedDescription, details: nil))
      return
    }

    guard let presenter = Self.topViewController() else {
      try? FileManager.default.removeItem(at: source)
      result(
        FlutterError(
          code: "no-view-controller", message: "書き出しパネルを表示できませんでした。", details: nil))
      return
    }

    let picker: UIDocumentPickerViewController
    if #available(iOS 14.0, *) {
      picker = UIDocumentPickerViewController(forExporting: [source], asCopy: true)
    } else {
      // iOS 13 には forExporting: が無い。exportToService も同じくコピーを作る。
      picker = UIDocumentPickerViewController(url: source, in: .exportToService)
    }

    let delegate = PickerDelegate { [weak self] saved in
      try? FileManager.default.removeItem(at: source)
      self?.pendingDelegate = nil
      result(saved)
    }
    pendingDelegate = delegate
    picker.delegate = delegate
    presenter.present(picker, animated: true)
  }

  /// 一番手前の view controller。Flutter のダイアログは UIKit の
  /// presentation を挟まないが、念のため presented を辿っておく。
  private static func topViewController() -> UIViewController? {
    var top =
      UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first(where: \.isKeyWindow)?
      .rootViewController
    while let presented = top?.presentedViewController { top = presented }
    return top
  }

  /// 選択 / キャンセルのどちらでも、Dart へちょうど 1 回だけ応答する。
  private final class PickerDelegate: NSObject, UIDocumentPickerDelegate {
    private var onFinish: ((Bool) -> Void)?

    init(onFinish: @escaping (Bool) -> Void) {
      self.onFinish = onFinish
    }

    func documentPicker(
      _ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]
    ) {
      finish(saved: !urls.isEmpty)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
      finish(saved: false)
    }

    private func finish(saved: Bool) {
      let callback = onFinish
      onFinish = nil
      callback?(saved)
    }
  }
}
