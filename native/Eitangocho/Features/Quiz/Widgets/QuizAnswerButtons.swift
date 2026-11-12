#if os(macOS)
  import SwiftUI

  /// 出題中のカードの下のボタンの段(答えを表示 / 忘れていた・覚えている)と注記(Flutter 版の QuizAnswerButtons)。
  ///
  /// 答えの前後で段の高さを変えない(カードの位置が変わらないように。iOS と同じ)。「答えを表示」は回答のボタンと
  /// 同じ位置に重ね、下の注記は答えの前は透明にして場所だけ取る。
  /// 「忘れていた」は iOS と同じ淡い赤のボタンにする(主ボタンの「覚えている」より控えめに)。
  struct QuizAnswerButtons: View {
    let revealed: Bool
    let onReveal: () -> Void
    let onForgot: () -> Void
    let onKnew: () -> Void

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    var body: some View {
      VStack(spacing: px(8)) {
        ZStack {
          HStack(spacing: px(10)) {
            AppSoftButton(
              label: String(localized: .quizForgot), color: colors.danger, background: colors.dangerSoftButton,
              action: onForgot)
            AppFilledButton(
              label: String(localized: .quizRemembered), verticalPadding: 11, borderRadius: 9, expands: true,
              action: onKnew)
          }
          .opacity(revealed ? 1 : 0)
          .allowsHitTesting(revealed)
          if !revealed {
            AppFilledButton(
              label: String(localized: .showAnswer), verticalPadding: 11, borderRadius: 9, expands: true,
              action: onReveal)
          }
        }
        AppText(.quizForgotHint, style: AppTextStyle(size: 11))
          .foregroundStyle(colors.textTertiary)
          .multilineTextAlignment(.center)
          .opacity(revealed ? 1 : 0)
      }
    }
  }
#endif
