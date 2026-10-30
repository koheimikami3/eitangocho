import SwiftUI

/// 学習中 0 件の空の状態。案内文 + 登録への導線(Flutter 版の LearningEmptyState)。
struct LearningEmptyState: View {
  let onRegister: () -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    VStack(spacing: 0) {
      AppText(.learningEmpty, style: AppTextStyle(size: 14, height: 1.7))
        .foregroundStyle(colors.textTertiary)
        .multilineTextAlignment(.center)
      Spacer().frame(height: px(14))
      AppFilledButton(label: String(localized: .addWord), fontSize: 13, action: onRegister)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
