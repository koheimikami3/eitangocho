import SwiftUI

/// 破線の枠(「訳を表示」ボタン用)。Flutter 版の DottedBorderBox。
/// 線は枠の縁の上に引く(Flutter の CustomPaint と同じく、線の半分が外に出る)。
struct DottedBorderBox<Content: View>: View {
  var backgroundColor: Color?
  @ViewBuilder let content: () -> Content

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    content()
      .padding(.horizontal, px(10))
      .padding(.vertical, px(8))
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(backgroundColor ?? .clear)
      .overlay(
        RoundedRectangle(cornerRadius: px(7))
          .stroke(colors.borderAlpha(18), style: StrokeStyle(lineWidth: px(1), dash: [px(4), px(3)]))
      )
  }
}
