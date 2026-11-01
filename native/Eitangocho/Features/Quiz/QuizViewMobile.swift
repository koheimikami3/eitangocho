#if os(iOS)
  import EitangochoData
  import SwiftUI

  /// iOS 版のフラッシュクイズ(Flutter 版の QuizViewMobile)。
  ///
  /// 出題の進行は macOS 版と同じ `QuizModel` を共有し、見た目と操作(キー操作を持たない)だけが異なる。
  struct QuizViewMobile: View {
    let quiz: QuizModel
    let shell: MainShellModel
    let settings: SettingsStore

    @Environment(\.ads) private var ads
    @Environment(\.purchase) private var purchase
    @Environment(\.quizRectanglePreloader) private var rectanglePreloader
    @Environment(\.quizInterstitial) private var interstitial

    var body: some View {
      // 縦中央に置き、答えの表示で背が伸びたときはスクロールにする。
      GeometryReader { geometry in
        ScrollView {
          content
            .frame(maxWidth: .infinity, minHeight: max(geometry.size.height - 40, 0))
            .padding(20)
        }
      }
      // 答えている間に、結果の画面のレクタングルとインタースティシャルを読み込んでおく
      // (レクタングルは幅に関わらず同じ大きさなので幅は使わない)。
      .onChange(of: quiz.phase == .active, initial: true) { _, active in
        guard active, let ads, let purchase else { return }
        rectanglePreloader?.prepare(width: 0, ads: ads, purchase: purchase)
        interstitial?.prepare(ads: ads, purchase: purchase)
      }
    }

    @ViewBuilder
    private var content: some View {
      switch quiz.phase {
      case .empty:
        MobileQuizEmptyState { shell.selectView(.learning) }
      case .done:
        // インタースティシャルを出している間は、結果の画面(とそのレクタングル)を作らない。
        if interstitial?.isHoldingResult == true {
          Color.clear
        } else {
          MobileQuizResultView(
            okCount: quiz.okCount, forgotWords: quiz.forgotWords,
            onContinue: { quiz.start(trigger: .continued) }, onToLearning: { shell.selectView(.learning) },
            onOpenPro: { shell.selectView(.settings) })
        }
      case .active:
        if let word = quiz.current {
          MobileActiveQuiz(quiz: quiz, word: word, direction: settings.quizDirection, onAnswer: answer)
        }
      }
    }

    /// 回答する。最後の問題なら、出せるインタースティシャルがあるときは結果の画面を待たせてから答え、
    /// 回が終わったら広告を出す(閉じると結果の画面になる)。
    private func answer(knew: Bool) {
      var holding = false
      if quiz.isOnLastQuestion, let interstitial, let purchase {
        holding = interstitial.holdResultIfReady(purchase: purchase)
      }
      Task {
        if knew { await quiz.answerKnew() } else { await quiz.answerForgot() }
        if holding { await interstitial?.present(roundFinished: quiz.phase == .done) }
      }
    }
  }

  /// 出題中の進捗・カード・回答ボタン。
  private struct MobileActiveQuiz: View {
    let quiz: QuizModel
    let word: Word
    let direction: QuizDirection
    /// 回答(true = 覚えている)。最後の問題でインタースティシャルを挟むため、親が受け持つ。
    let onAnswer: (Bool) -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      // en→ja: 表面 = 英単語 + IPA、裏面 = 訳。ja→en: 表面 = 訳(IPA なし)、裏面 = 英単語。
      let isJaToEn = direction == .jaToEn
      VStack(spacing: 16) {
        AppText("\(quiz.index + 1) / \(quiz.questions.count)", style: AppTextStyle(size: 12))
          .foregroundStyle(palette.textAlpha(45))
        MobileQuizCard(
          front: isJaToEn ? word.meaning : word.word,
          ipa: isJaToEn ? "" : word.ipa,
          revealed: quiz.revealed,
          back: isJaToEn ? word.word : word.meaning,
          exampleEn: word.exampleEn,
          exampleTranslation: word.exampleTranslation,
          englishWord: word.word,
          pronunciationOnFront: !isJaToEn)
        if !quiz.revealed {
          MobileFilledButton(label: String(localized: .showAnswer), expands: true) { quiz.reveal() }
        } else {
          VStack(spacing: 10) {
            HStack(spacing: 10) {
              MobileQuizSecondaryButton(label: String(localized: .quizForgot), color: palette.danger) {
                onAnswer(false)
              }
              MobileFilledButton(label: String(localized: .quizRemembered), expands: true) {
                onAnswer(true)
              }
            }
            AppText(.quizForgotHint, style: AppTextStyle(size: 11))
              .foregroundStyle(palette.textAlpha(38))
          }
        }
      }
      .multilineTextAlignment(.center)
    }
  }

  /// 影で浮かせた面のボタン(クイズの副操作。Flutter 版の _SecondaryButton)。
  private struct MobileQuizSecondaryButton: View {
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
      MobileRaisedSurface(cornerRadius: 12, padding: EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14), action: action) {
        AppText(label, style: AppTextStyle(size: 15, weight: .w600))
          .foregroundStyle(color)
          .frame(maxWidth: .infinity)
      }
    }
  }
#endif
