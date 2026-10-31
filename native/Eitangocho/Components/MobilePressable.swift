#if os(iOS)
  import SwiftUI

  /// MobilePressable の押下演出。値はデザインの `:active` スタイル(Flutter 版の MobilePressStyle)。
  enum MobilePressStyle {
    /// 浮いた面(カード・面ボタン)。縮むだけで、地・影・位置は変えない。
    case card
    /// 主ボタン・ピル形ボタン。縮んで薄くなる。
    case button
    /// タブバーの項目(Flutter 版の自前のタブバー。Swift 版は標準のタブバーなので使わない)。
    case tab
    /// リストの行。形は変えず、地の色だけを呼び出し側が変える。
    case row
    /// シートの「キャンセル」「閉じる」など文字だけのボタン。薄くなるだけ。
    case text

    var scale: CGFloat {
      switch self {
      case .card: 0.972
      case .button: 0.965
      case .tab: 0.94
      case .row, .text: 1
      }
    }

    var opacity: Double {
      switch self {
      case .card, .row: 1
      case .button: 0.72
      case .tab: 0.6
      case .text: 0.4
      }
    }
  }

  /// 押している間だけ見た目を変える iOS 版のタップ領域(Flutter 版の MobilePressable)。
  ///
  /// 縮小・透過は `style` に従ってここで行い、地の色や影の切り替えは中身に pressed を渡して
  /// 呼び出し側に任せる(面ごとに違うため)。透明な所も押せる(Flutter の HitTestBehavior.opaque)。
  /// `action` が nil なら押せず、見た目も変えない。
  struct MobilePressable<Content: View>: View {
    var style: MobilePressStyle = .button
    let action: (() -> Void)?
    @ViewBuilder let content: (_ pressed: Bool) -> Content

    var body: some View {
      // 中身は Button のラベルに置き、押している状態は環境値で渡す。ButtonStyle に中身の閉包を持たせると、
      // 親の状態が変わっても makeBody が呼び直されず、中身が古いまま残るため。
      Button {
        action?()
      } label: {
        PressedContent(content: content)
      }
      .buttonStyle(PressStyle(style: style))
      .disabled(action == nil)
    }
  }

  extension MobilePressable {
    /// 押している間の見た目を中身で変えないとき。
    init(style: MobilePressStyle = .button, action: (() -> Void)?, @ViewBuilder content: @escaping () -> Content) {
      self.init(style: style, action: action) { _ in content() }
    }
  }

  extension EnvironmentValues {
    /// MobilePressable の中身が押されている間か。
    @Entry fileprivate var mobilePressed = false
  }

  /// 押している状態を環境値から受け取って中身を組む。
  private struct PressedContent<Content: View>: View {
    let content: (Bool) -> Content
    @Environment(\.mobilePressed) private var pressed

    var body: some View { content(pressed) }
  }

  private struct PressStyle: ButtonStyle {
    let style: MobilePressStyle

    /// デザインの transition(0.09〜0.1s)に合わせる。
    private static var duration: Double { 0.1 }

    func makeBody(configuration: Configuration) -> some View {
      let pressed = configuration.isPressed
      configuration.label
        .environment(\.mobilePressed, pressed)
        .contentShape(Rectangle())
        .scaleEffect(pressed ? style.scale : 1)
        .opacity(pressed ? style.opacity : 1)
        .animation(.easeOut(duration: Self.duration), value: pressed)
    }
  }
#endif
