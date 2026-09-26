import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // プロトタイプ準拠: サイドバーが信号機ボタンの背後まで届く見た目にするため
    // タイトルバーを透明化し、コンテンツをウィンドウ全面に広げる
    self.titlebarAppearsTransparent = true
    self.titleVisibility = .hidden
    self.styleMask.insert(.fullSizeContentView)
    // 初期サイズは画面(visibleFrame)比で決める。固定 px だとディスプレイの
    // 解像度・スケーリング設定によって見た目の大きさが変わってしまうため。
    // 比率はユーザー要望のサイズ(4K 相当ディスプレイで約 6 割 x 7.5 割)から算出。
    if let screen = NSScreen.main {
      let visible = screen.visibleFrame
      self.setContentSize(
        NSSize(width: visible.width * 0.6, height: visible.height * 0.75))
      self.center()
    } else {
      self.setContentSize(NSSize(width: 1440, height: 900))
    }
    // 最小幅は UI スケール 1.5 でツールバーが溢れない下限の目安
    self.minSize = NSSize(width: 1080, height: 700)

    RegisterGeneratedPlugins(registry: flutterViewController)
    // iCloud 同期は plugin ではなく自前の MethodChannel なので個別に登録する。
    IcloudFileStorePlugin.register(with: flutterViewController.engine.binaryMessenger)
    // 発音確認のウィンドウも同じく自前の MethodChannel。
    PronunciationWindowPlugin.register(
      with: flutterViewController.engine.binaryMessenger, parentWindow: self)

    super.awakeFromNib()
  }
}
