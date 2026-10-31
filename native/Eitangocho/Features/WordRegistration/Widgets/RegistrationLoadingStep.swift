import SwiftUI

/// 辞書を引いている間の表示(回る弧 + 文言)。Flutter 版の RegistrationLoadingStep。
struct RegistrationLoadingStep: View {
  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      CircularProgress(color: colors.accent, size: 28, lineWidth: 3)
      Spacer().frame(height: px(12))
      AppText(.fetchingDictionary, style: AppTextStyle(size: 13))
        .foregroundStyle(colors.textSecondary)
    }
    .padding(.vertical, px(24))
  }
}
