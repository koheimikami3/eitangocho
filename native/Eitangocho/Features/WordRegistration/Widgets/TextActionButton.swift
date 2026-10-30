import SwiftUI

/// 文字だけのボタン(登録フォームの「キャンセル」。ホバーで濃くする)。
struct TextActionButton: View {
  let label: String
  let action: () -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @State private var isHovered = false

  var body: some View {
    AppText(label, style: AppTextStyle(size: 14))
      .foregroundStyle(isHovered ? colors.textPrimary : colors.textAlpha(50))
      .padding(.horizontal, px(4))
      .padding(.vertical, px(9))
      .hoverTap($isHovered, in: Rectangle(), action: action)
  }
}
