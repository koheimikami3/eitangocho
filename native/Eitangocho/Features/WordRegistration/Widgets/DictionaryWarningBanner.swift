import SwiftUI

/// 辞書未収録などの警告(フォームの上部に出す。Flutter 版の DictionaryWarningBanner)。
struct DictionaryWarningBanner: View {
  let message: String

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: px(8))
    AppText(message, style: AppTextStyle(size: 13))
      .foregroundStyle(colors.warningBannerForeground)
      .padding(.horizontal, px(14 + 1))
      .padding(.vertical, px(10 + 1))
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(shape.fill(colors.warningBannerBackground))
      .overlay(shape.strokeBorder(colors.warningBannerBorder, lineWidth: px(1)))
  }
}
