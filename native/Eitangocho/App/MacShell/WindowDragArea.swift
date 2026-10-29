#if os(macOS)
  import AppKit
  import SwiftUI

  /// macOS のタイトルバーの代わりになる領域(Flutter 版の WindowDragArea と WindowControlPlugin)。
  /// ドラッグでウィンドウを動かし、ダブルクリックでシステム設定どおりの動作をする。
  ///
  /// タイトルバーを透明にして中身を全面に広げているので、サイドバーの上端と
  /// ツールバーでは標準のタイトルバーの動作が起きない。そこへ背面に敷いて戻す。
  /// 前面の部品(ボタン・検索欄)が当たった所ではこちらに届かないので、空いている所だけが反応する。
  struct WindowDragArea: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { DragView() }
    func updateNSView(_ nsView: NSView, context: Context) {}

    private final class DragView: NSView {
      override func mouseDown(with event: NSEvent) {
        guard let window else { return }
        if event.clickCount == 2 {
          Self.handleDoubleClick(window)
        } else {
          // 押した時点のイベントを渡すと、以降の移動は AppKit が追従する。
          window.performDrag(with: event)
        }
      }

      /// システム設定「タイトルバーをダブルクリックして」に従う。
      /// 拡大(zoom)は 1 回目で画面いっぱい、もう一度で元の大きさと位置に戻る。
      private static func handleDoubleClick(_ window: NSWindow) {
        switch UserDefaults.standard.string(forKey: "AppleActionOnDoubleClick") {
        case "Minimize": window.miniaturize(nil)
        case "None": break
        // "Maximize" / "Fill"(macOS 15 以降)/ 未設定はすべて拡大にする。
        default: window.zoom(nil)
        }
      }
    }
  }
#endif
