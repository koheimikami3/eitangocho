import EitangochoData
import SwiftUI

/// クイズの結果の画面(復習完了・成績・忘れていた単語の一覧・次の行動)。Flutter 版の QuizResultView。
struct QuizResultView: View {
  let okCount: Int
  let forgotWords: [Word]
  let onContinue: () -> Void
  let onToLearning: () -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    VStack(spacing: 0) {
      AppText(.quizDone, style: AppTextStyle(size: 22, weight: .w700))
        .foregroundStyle(colors.textPrimary)
      Spacer().frame(height: px(6))
      AppText(.quizSummary(okCount, forgotWords.count), style: AppTextStyle(size: 14))
        .foregroundStyle(colors.textSecondary)
      if !forgotWords.isEmpty {
        Spacer().frame(height: px(16))
        QuizForgotList(words: forgotWords)
      }
      Spacer().frame(height: px(16))
      HStack(spacing: px(10)) {
        AppFilledButton(
          label: String(localized: .quizContinue), verticalPadding: 11, borderRadius: 9, expands: true,
          action: onContinue)
        // iOS と同じく 2 つとも主ボタン(どちらも次の行動として同格)。
        AppFilledButton(
          label: String(localized: .toLearningList), verticalPadding: 11, borderRadius: 9, expands: true,
          action: onToLearning)
      }
    }
    .multilineTextAlignment(.center)
  }
}

/// 忘れていた単語の一覧。iOS の一覧と同じく、枠線なし + 影の面に淡い赤の見出しを載せる。
private struct QuizForgotList: View {
  let words: [Word]

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: px(AppDimensions.mobileCardRadius))
    VStack(spacing: 0) {
      // 下の区切り線の太さの分は下の余白に足す(Flutter の Container は枠線の幅を内側の余白に足す)。
      AppText(.quizForgotWordsHeader, style: AppTextStyle(size: 12, weight: .w700))
        .foregroundStyle(colors.danger)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: px(10), leading: px(16), bottom: px(10 + 1), trailing: px(16)))
        .background(colors.dangerSoft)
        .overlay(alignment: .bottom) { line }
      ForEach(Array(words.enumerated()), id: \.offset) { index, word in
        // 区切り線は行と行の間だけ。最後の行にも引くとカードの下端と 2 本並んで太く見える。
        let isLast = index == words.count - 1
        HStack(alignment: .firstTextBaseline, spacing: px(12)) {
          AppText(word.word, style: AppTextStyle(size: 13, weight: .w600))
            .foregroundStyle(colors.textPrimary)
            .frame(width: px(110), alignment: .leading)
          AppText(word.meaning, style: AppTextStyle(size: 13))
            .foregroundStyle(colors.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .multilineTextAlignment(.leading)
        .padding(EdgeInsets(top: px(9), leading: px(16), bottom: px(isLast ? 9 : 9 + 1), trailing: px(16)))
        .overlay(alignment: .bottom) {
          if !isLast { line }
        }
      }
    }
    .background(colors.surface)
    .clipShape(shape)
    .appShadows(colors.elevation, in: shape, scale: px.factor)
  }

  private var line: some View {
    Rectangle().fill(colors.rowLine).frame(height: px(1))
  }
}
