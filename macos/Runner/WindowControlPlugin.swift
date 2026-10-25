// 本体ウィンドウの移動と、タイトルバーのダブルクリック動作を Flutter から呼ぶ。
//
// 本体はタイトルバーを透明にして Flutter の描画を全面に広げている
// (MainFlutterWindow)。そのためタイトルバー相当の位置でも mouse イベントは
// Flutter が受け取り、macOS 標準の「ドラッグで移動」「ダブルクリックで拡大」が
// 起きない。Flutter 側(WindowDragArea)で拾った操作をここで標準動作に戻す。
//
// アプリの外観(ライト / ダーク)を AppKit が描く部分に反映するのもここで行う。

import Cocoa
import FlutterMacOS

final class WindowControlPlugin: NSObject {
  /// Dart 側(window_control.dart)と合わせる。
  private static let channelName = "eitangocho/window"

  private weak var window: NSWindow?

  static func register(with messenger: FlutterBinaryMessenger, window: NSWindow) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    let instance = WindowControlPlugin()
    instance.window = window
    // instance はこのクロージャが保持し続ける。
    channel.setMethodCallHandler { call, result in
      instance.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let window = window else {
      result(nil)
      return
    }
    switch call.method {
    case "startDrag":
      // ドラッグ開始時点のイベントを渡すと、以降の移動は AppKit が追従する。
      if let event = window.currentEvent {
        window.performDrag(with: event)
      }
      result(nil)
    case "titleBarDoubleClick":
      handleDoubleClick(window)
      result(nil)
    case "setAppearance":
      // 設定はアプリ全体の外観なので、ウィンドウ単位ではなく NSApp に当てる
      // (発音確認のウィンドウ・ファイル選択パネルにも行き渡らせるため)。
      let dark = call.arguments as? Bool ?? false
      NSApp.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// システム設定「タイトルバーをダブルクリックして」に従う。
  /// 拡大(zoom)は 1 回目で画面いっぱい、もう一度で元の大きさと位置に戻る。
  private func handleDoubleClick(_ window: NSWindow) {
    switch UserDefaults.standard.string(forKey: "AppleActionOnDoubleClick") {
    case "Minimize":
      window.miniaturize(nil)
    case "None":
      break
    default:
      // "Maximize" / "Fill"(macOS 15 以降)/ 未設定はすべて拡大にする。
      window.zoom(nil)
    }
  }
}
