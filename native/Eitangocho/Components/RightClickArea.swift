#if os(macOS)
  import AppKit
  import SwiftUI

  /// 右クリック(と control + クリック)だけを受ける透明な面。カード・行に重ねて置く。
  ///
  /// SwiftUI の contextMenu は標準のメニューを出すので、Flutter 版と同じ見た目の
  /// メニュー(AppOverlay)を出すために、押した位置だけを受け取る。
  /// 左クリック・ホバーは下の SwiftUI の部品にそのまま通す。
  struct RightClickArea: NSViewRepresentable {
    /// 押した位置(ウィンドウの左上が原点)。
    let action: (CGPoint) -> Void

    func makeNSView(context: Context) -> ClickView {
      let view = ClickView()
      view.action = action
      return view
    }

    func updateNSView(_ nsView: ClickView, context: Context) {
      nsView.action = action
    }

    final class ClickView: NSView {
      var action: ((CGPoint) -> Void)?

      override func hitTest(_ point: NSPoint) -> NSView? {
        guard let event = NSApp.currentEvent, Self.isContextClick(event) else { return nil }
        return super.hitTest(point)
      }

      override func rightMouseDown(with event: NSEvent) { report(event) }

      override func mouseDown(with event: NSEvent) {
        if Self.isContextClick(event) { report(event) }
      }

      private static func isContextClick(_ event: NSEvent) -> Bool {
        event.type == .rightMouseDown || (event.type == .leftMouseDown && event.modifierFlags.contains(.control))
      }

      private func report(_ event: NSEvent) {
        guard let contentView = window?.contentView else { return }
        let point = contentView.convert(event.locationInWindow, from: nil)
        // AppKit の座標は左下が原点なので、SwiftUI と同じ左上原点に直す。
        let y = contentView.isFlipped ? point.y : contentView.bounds.height - point.y
        action?(CGPoint(x: point.x, y: y))
      }
    }
  }
#endif
