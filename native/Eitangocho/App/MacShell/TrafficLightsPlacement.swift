#if os(macOS)
  import AppKit
  import SwiftUI

  /// 信号機ボタン(閉じる・しまう・拡大)を、標準のサイドバーのアプリ(メモなど)と同じく窓の角から内側へ寄せて置き直す。
  ///
  /// タイトルバーを隠した窓では、ボタンは窓の角のすぐそばに置かれ、標準のアプリより外側に寄って見える。
  /// タイトルバーの入れ物を下へ広げてボタンを動かす。
  /// OS は窓の大きさを変えたとき・フルスクリーンから戻ったときなどにボタンを元の位置へ戻すので、そのたびに置き直す。
  ///
  /// タイトルバーの入れ物を広げても、ボタン以外の所のクリックはその下の中身に届く
  /// (タイトルバーが透明で中身を全面に広げた窓のため。WindowDragArea が要るのも同じ理由)。
  struct TrafficLightsPlacement: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { PlacementView() }
    func updateNSView(_ nsView: NSView, context: Context) {}

    /// 窓の左上から、閉じるボタンの中心までの距離(macOS 27 のメモ・Claude の窓を測った値)。
    /// 窓の縁に対する寸法なので、表示倍率では変えない。
    private static let centerX: CGFloat = 24
    private static let centerY: CGFloat = 23

    private final class PlacementView: NSView {
      private var observers: [NSObjectProtocol] = []

      override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        observers.forEach(NotificationCenter.default.removeObserver)
        observers = []
        guard let window else { return }
        let names: [Notification.Name] = [
          NSWindow.didResizeNotification, NSWindow.didEndLiveResizeNotification,
          NSWindow.didExitFullScreenNotification, NSWindow.didBecomeKeyNotification,
          NSWindow.didResignKeyNotification,
        ]
        observers = names.map { name in
          NotificationCenter.default.addObserver(forName: name, object: window, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.place() }
          }
        }
        // 窓が最初に並べ終わった後に置く(並べる前に動かすと、OS の配置で上書きされる)。
        DispatchQueue.main.async { [weak self] in self?.place() }
      }

      private func place() {
        // フルスクリーンではボタンは上端から降りてくる別の帯に移るので、OS の配置のままにする。
        guard let window, !window.styleMask.contains(.fullScreen),
          let close = window.standardWindowButton(.closeButton),
          let miniaturize = window.standardWindowButton(.miniaturizeButton),
          let zoom = window.standardWindowButton(.zoomButton),
          let titlebar = close.superview, let container = titlebar.superview
        else { return }
        let height = TrafficLightsPlacement.centerY * 2
        if container.frame.height != height {
          container.frame = NSRect(
            x: container.frame.minX, y: window.frame.height - height, width: container.frame.width, height: height)
        }
        titlebar.frame = container.bounds
        // ボタンどうしの間隔は OS の配置のまま使う(3 つを同じだけずらすので、何度置き直しても変わらない)。
        let spacing = miniaturize.frame.minX - close.frame.minX
        for (index, button) in [close, miniaturize, zoom].enumerated() {
          button.setFrameOrigin(
            NSPoint(
              x: TrafficLightsPlacement.centerX - button.frame.width / 2 + CGFloat(index) * spacing,
              y: (height - button.frame.height) / 2))
        }
      }
    }
  }
#endif
