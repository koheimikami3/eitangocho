#if os(macOS)
  import AppKit
  import WebKit

  /// macOS 版の発音確認ウィンドウ。Google 翻訳をアプリ内の別ウィンドウ(WKWebView)で開く
  /// (Flutter 版の PronunciationWindowPlugin を移したもの)。
  ///
  /// ウィンドウは 1 枚だけ持ち、別の単語では中身を差し替えて使い回す
  /// (単語ごとに増えると閉じる手間が増えるため)。
  final class PronunciationWindowController: NSObject, NSWindowDelegate {
    static let shared = PronunciationWindowController()

    /// 初めて開くときの、本体ウィンドウに対する大きさの比率。
    /// ページをアプリと同じ拡大率で出すため、固定の大きさだと窮屈になる。
    private static let sizeRatio = NSSize(width: 0.75, height: 0.85)

    /// 本体ウィンドウが取れないときの大きさ。
    private static let fallbackSize = NSSize(width: 1200, height: 900)

    private var window: NSWindow?
    private var webView: WKWebView?
    private weak var parentWindow: NSWindow?

    /// `zoom` はページの拡大率(1.0 で等倍)。アプリの uiScale を渡し、
    /// ページの文字をアプリ本体と同じ大きさに揃える。
    func open(url: URL, title: String, zoom: Double) {
      // 押したのは本体ウィンドウなので、そのときのキーウィンドウを親とみなす。
      if let key = NSApp.keyWindow, key !== window { parentWindow = key }
      let isNew = window == nil
      let window = self.window ?? makeWindow()
      window.title = title
      webView?.pageZoom = CGFloat(zoom)
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
      let window = ClosableWindow(
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
      return NSSize(
        width: parent.frame.width * Self.sizeRatio.width, height: parent.frame.height * Self.sizeRatio.height)
    }

    /// 本体ウィンドウの中央に重ねる(画面中央だと本体から離れて見えるため)。
    private func centerOnParent(_ window: NSWindow) {
      guard let parent = parentWindow else {
        window.center()
        return
      }
      let size = window.frame.size
      window.setFrameOrigin(NSPoint(x: parent.frame.midX - size.width / 2, y: parent.frame.midY - size.height / 2))
    }

    func windowWillClose(_ notification: Notification) {
      // 閉じた後も再生が続かないよう、ページを破棄しておく。
      webView?.load(URLRequest(url: URL(string: "about:blank")!))
    }
  }

  /// Esc と ⌘W で閉じられるウィンドウ(Esc は iOS のシートを閉じる感覚に合わせる)。
  private final class ClosableWindow: NSWindow {
    override func cancelOperation(_ sender: Any?) {
      close()
    }

    // メニューバーに標準の「閉じる」(⌘W)を置いていない(本体ウィンドウで ⌘W が効かないように)
    // ので、このウィンドウだけで受ける。キーウィンドウにはメニューより先に key equivalent が回ってくる。
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
      if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command,
        event.charactersIgnoringModifiers?.lowercased() == "w"
      {
        performClose(nil)
        return true
      }
      return super.performKeyEquivalent(with: event)
    }
  }
#endif
