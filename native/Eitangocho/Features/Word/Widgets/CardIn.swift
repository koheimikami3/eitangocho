import SwiftUI

/// カードの出現アニメーション(不透明度 0→1 + 下から 4 上がる、0.25 秒の ease)。
/// Flutter 版の CardIn と同じく、表示されたときに一度だけ再生する。
struct CardIn: ViewModifier {
  @Environment(\.uiScale) private var px
  @State private var appeared = false

  func body(content: Content) -> some View {
    content
      .opacity(appeared ? 1 : 0)
      .offset(y: appeared ? 0 : px(4))
      .onAppear {
        // Flutter の Curves.ease と同じ制御点。
        withAnimation(.timingCurve(0.25, 0.1, 0.25, 1, duration: 0.25)) { appeared = true }
      }
  }
}
