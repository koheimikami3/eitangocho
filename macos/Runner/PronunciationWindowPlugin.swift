// macOS 版の発音確認ウィンドウ。Google 翻訳をアプリ内の別ウィンドウ(WKWebView)で開く。
//
// iOS は webview_flutter でシートに埋め込んでいるが、macOS の platform view は
// ジェスチャに未対応で、埋め込むと再生ボタンを押せない。Flutter の画面には
// 埋め込まず、ネイティブのウィンドウに WKWebView を直接置けばこの制約を受けない。
// macOS 専用なので shared/ ではなく macos/Runner に置く。

import Cocoa
import FlutterMacOS
import WebKit

final class PronunciationWindowPlugin: NSObject, NSWindowDelegate {
  /// Dart 側(pronunciation_window.dart)と合わせる。
  private static let channelName = "eitangocho/pronunciation"

  /// 初めて開くときの、本体ウィンドウに対する大きさの比率。
  /// ページをアプリと同じ拡大率で出すため、固定サイズだと窮屈になる。
  private static let sizeRatio = NSSize(width: 0.75, height: 0.85)

  /// 本体ウィンドウが取れないときの大きさ。
  private static let fallbackSize = NSSize(width: 1200, height: 900)

  /// ウィンドウは 1 枚だけ持ち、別の単語では中身を差し替えて使い回す
  /// (単語ごとに増えると閉じる手間が増えるため)。
  private var window: NSWindow?
  private var webView: WKWebView?
  private weak var parentWindow: NSWindow?

  static func register(with messenger: FlutterBinaryMessenger, parentWindow: NSWindow) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    let instance = PronunciationWindowPlugin()
    instance.parentWindow = parentWindow
    // instance はこのクロージャが保持し続ける。
    channel.setMethodCallHandler { call, result in
      instance.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "open":
      guard let args = call.arguments as? [String: Any],
        let urlString = args["url"] as? String,
        let url = URL(string: urlString)
      else {
        result(FlutterError(code: "bad-args", message: "url が渡されていません。", details: nil))
        return
      }
      open(
        url: url,
        title: args["title"] as? String ?? "",
        zoom: args["zoom"] as? Double ?? 1)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func open(url: URL, title: String, zoom: Double) {
    let isNew = self.window == nil
    let window = self.window ?? makeWindow()
    window.title = title
    if #available(macOS 11.0, *) {
      webView?.pageZoom = CGFloat(zoom)
    }
    webView?.load(URLRequest(url: url))
    // 初回だけ本体に合わせた大きさにする。2 回目以降はユーザーが変えた
    // 大きさを保ち、表示中なら位置もそのままにする。
    if isNew {
      window.setContentSize(initialSize())
    }
    if !window.isVisible {
      centerOnParent(window)
    }
    window.makeKeyAndOrderFront(nil)
  }

  private func makeWindow() -> NSWindow {
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    let window = PronunciationWindow(
      contentRect: NSRect(origin: .zero, size: Self.fallbackSize),
      styleMask: [.titled, .closable, .resizable, .miniaturizable],
      backing: .buffered,
      defer: false)
    // 閉じても解放せず、次に開くときに使い回す。
    window.isReleasedWhenClosed = false
    window.contentView = webView
    window.minSize = NSSize(width: 480, height: 400)
    window.delegate = self
    self.window = window
    self.webView = webView
    return window
  }

  private func initialSize() -> NSSize {
    guard let parent = parentWindow else { return Self.fallbackSize }
    let size = parent.frame.size
    return NSSize(
      width: size.width * Self.sizeRatio.width,
      height: size.height * Self.sizeRatio.height)
  }

  /// 本体ウィンドウの中央に重ねる(画面中央だと本体から離れて見えるため)。
  private func centerOnParent(_ window: NSWindow) {
    guard let parent = parentWindow else {
      window.center()
      return
    }
    let parentFrame = parent.frame
    let size = window.frame.size
    window.setFrameOrigin(
      NSPoint(
        x: parentFrame.midX - size.width / 2,
        y: parentFrame.midY - size.height / 2))
  }

  func windowWillClose(_ notification: Notification) {
    // 閉じた後も再生が続かないよう、ページを破棄しておく。
    webView?.load(URLRequest(url: URL(string: "about:blank")!))
  }
}

/// Esc で閉じられる発音ウィンドウ(iOS のシートを閉じる感覚に合わせる)。
private final class PronunciationWindow: NSWindow {
  override func cancelOperation(_ sender: Any?) {
    close()
  }
}
