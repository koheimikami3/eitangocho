import SwiftUI

/// クイズの対象(学習済み)が 0 件のときの空の状態(Flutter 版の QuizEmptyState)。
struct QuizEmptyState: View {
  let onToLearning: () -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    VStack(spacing: 0) {
      AppText(.quizEmpty, style: AppTextStyle(size: 14, height: 1.8))
        .foregroundStyle(colors.textTertiary)
        .multilineTextAlignment(.center)
      Spacer().frame(height: px(14))
      // iOS と同じく主ボタンにする(次に取る行動がこれしかないため)。
      AppFilledButton(label: String(localized: .toLearningList), fontSize: 13, action: onToLearning)
    }
  }
}
