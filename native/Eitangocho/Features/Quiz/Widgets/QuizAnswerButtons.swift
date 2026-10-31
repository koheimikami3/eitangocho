import SwiftUI

/// 答えを開いた後の回答ボタンの列(忘れていた / 覚えている)と注記(Flutter 版の QuizAnswerButtons)。
struct QuizAnswerButtons: View {
  let onForgot: () -> Void
  let onKnew: () -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: px(10)) {
        // iOS と同じく、枠線ではなく影で浮かせた面の副ボタンにする。
        AppRaisedButton(
          label: String(localized: .quizForgot), textColor: colors.danger, verticalPadding: 11, borderRadius: 9,
          expands: true, action: onForgot)
        AppFilledButton(
          label: String(localized: .quizRemembered), verticalPadding: 11, borderRadius: 9, expands: true,
          action: onKnew)
      }
      Spacer().frame(height: px(8))
      AppText(.quizForgotHint, style: AppTextStyle(size: 11))
        .foregroundStyle(colors.textTertiary)
        .multilineTextAlignment(.center)
    }
  }
}
