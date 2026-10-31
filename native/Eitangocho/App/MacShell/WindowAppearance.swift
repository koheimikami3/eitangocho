#if os(macOS)
  import AppKit

  /// アプリの外観(ライト / ダーク)を AppKit が描く部分にも伝える。
  ///
  /// SwiftUI が描く部分は配色の環境値で切り替わるが、信号機ボタン・ファイル選択パネル・
  /// 発音確認のウィンドウ枠などは NSApp.appearance に従う。設定はアプリ全体の外観なので、
  /// ウィンドウ単位ではなく NSApp に当てる。
  enum WindowAppearance {
    static func apply(_ appearance: AppAppearance) {
      NSApp.appearance = NSAppearance(named: appearance == .dark ? .darkAqua : .aqua)
    }

    /// 初期のウィンドウの大きさ。画面(visibleFrame)比で決める。固定の値だと
    /// ディスプレイの解像度・スケーリング設定によって見た目の大きさが変わってしまうため。
    /// 比率はユーザー要望のサイズ(4K 相当ディスプレイで約 6 割 x 7.5 割)から算出(Flutter 版と同じ)。
    static var defaultSize: CGSize {
      guard let visible = NSScreen.main?.visibleFrame else { return CGSize(width: 1440, height: 900) }
      return CGSize(width: visible.width * 0.6, height: visible.height * 0.75)
    }

    /// 最小の大きさ。既定の表示倍率 1.5 でツールバーが溢れない下限の目安。
    static let minimumSize = CGSize(width: 1080, height: 700)
  }
#endif
