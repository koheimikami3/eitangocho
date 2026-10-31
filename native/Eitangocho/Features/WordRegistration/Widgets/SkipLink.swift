import SwiftUI

/// 「スキップして手動で入力する」のリンク。ホバーでは下線ではなく色を濃い青に変える。
struct SkipLink: View {
  let action: () -> Void

  @Environment(\.colors) private var colors
  @State private var isHovered = false

  var body: some View {
    AppText(.skipToManual, style: AppTextStyle(size: 13))
      .foregroundStyle(isHovered ? colors.accentOnSoft : colors.accent)
      .hoverTap($isHovered, in: Rectangle(), action: action)
      #if os(macOS)
        .pointerStyle(.link)
      #endif
  }
}
