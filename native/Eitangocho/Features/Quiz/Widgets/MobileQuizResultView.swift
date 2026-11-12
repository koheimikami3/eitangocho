#if os(iOS)
  import EitangochoData
  import SwiftUI

  /// iOS 版のクイズの結果の画面(成績・忘れていた単語の一覧・次の行動。Flutter 版の MobileQuizResultView)。
  ///
  /// 次の行動は 2.18.0 で「忘れた単語だけもう一度」(忘れた単語があるときの主ボタン)・「続ける」・「条件を変える」
  /// (入口へ)にした。クイズの後に学習済み→学習中へ戻す操作が多く、忘れた単語をその場で練習し直したい人が多いと見たため。
  struct MobileQuizResultView: View {
    let okCount: Int
    let forgotWords: [Word]
    /// 全部の回の一巡の案内(「一巡しました」か進み具合)。それ以外は nil。
    let cycleNote: String?
    let onRetry: () -> Void
    let onContinue: () -> Void
    let onChangeConditions: () -> Void
    /// 広告の下の Pro への導線を押したとき。
    let onOpenPro: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      VStack(spacing: 0) {
        // 学習中の単語からも出せるようになったので「復習完了」ではなく「クイズ完了」(2.18.0。macOS は学習済みだけなので
        // 今の「復習完了」のまま)。
        AppText(.quizCompleted, style: AppTextStyle(size: 22, weight: .w700))
          .foregroundStyle(palette.text)
        Spacer().frame(height: 6)
        AppText(.quizSummary(okCount, forgotWords.count), style: AppTextStyle(size: 14))
          .foregroundStyle(palette.textAlpha(60))
        if let cycleNote {
          Spacer().frame(height: 4)
          AppText(cycleNote, style: AppTextStyle(size: 13, weight: .w600))
            .foregroundStyle(palette.accent)
        }
        if !forgotWords.isEmpty {
          Spacer().frame(height: 16)
          MobileQuizForgotList(words: forgotWords)
        }
        // 上の余白は広告自身が持ち、読み込めなければ高さごと消えて今のレイアウトに戻る(Flutter 版と同じ)。
        MobileQuizRectangleAd(onOpenPro: onOpenPro)
        Spacer().frame(height: 16)
        // 塗りの主ボタンを必ず 1 つ置き、次に押すものをはっきりさせる。忘れた単語があれば「もう一度」、
        // 無ければ「続ける」を主にする(淡いボタンだけが並ぶと主役がいなくなるため)。
        VStack(spacing: 10) {
          if forgotWords.isEmpty {
            MobileFilledButton(label: String(localized: .quizContinue), expands: true, action: onContinue)
            secondaryButton(.quizChangeConditions, action: onChangeConditions)
          } else {
            MobileFilledButton(
              label: String(localized: .quizRetryForgotten(forgotWords.count)), expands: true, action: onRetry)
            HStack(spacing: 10) {
              secondaryButton(.quizContinue, action: onContinue)
              secondaryButton(.quizChangeConditions, action: onChangeConditions)
            }
          }
        }
      }
      .multilineTextAlignment(.center)
    }

    /// 結果の副ボタン(淡いアクセント色。主ボタンより控えめにする)。
    private func secondaryButton(_ label: LocalizedStringResource, action: @escaping () -> Void) -> some View {
      MobileSoftButton(
        label: String(localized: label), color: palette.accentOnSoft, background: palette.accentSoftButton,
        action: action)
    }
  }

  /// 忘れていた単語の一覧。淡い赤の見出しを載せた影の面(Flutter 版の _ForgotList)。
  private struct MobileQuizForgotList: View {
    let words: [Word]

    @Environment(\.palette) private var palette

    var body: some View {
      let shape = RoundedRectangle(cornerRadius: AppDimensions.mobileCardRadius)
      VStack(spacing: 0) {
        // グレーの見出しは地と見分けが付かなかったため、「忘れていた」に合わせて淡い赤の地 + 赤文字にする。
        // 下の区切り線の太さの分は下の余白に足す(Flutter の Container は枠線の幅を内側の余白に足す)。
        AppText(.quizForgotWordsHeader, style: AppTextStyle(size: 12, weight: .w700))
          .foregroundStyle(palette.danger)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(EdgeInsets(top: 10, leading: 16, bottom: 10 + 1, trailing: 16))
          .background(palette.dangerSoft)
          .overlay(alignment: .bottom) { line }
        ForEach(Array(words.enumerated()), id: \.offset) { index, word in
          // 区切り線は行と行の間だけ。最後の行にも引くとカードの下端と 2 本並んで太く見える。
          let isLast = index == words.count - 1
          HStack(alignment: .firstTextBaseline, spacing: 12) {
            AppText(word.word, style: AppTextStyle(size: 13, weight: .w600))
              .foregroundStyle(palette.text)
              .frame(width: 100, alignment: .leading)
            AppText(word.meaning, style: AppTextStyle(size: 13))
              .foregroundStyle(palette.textAlpha(60))
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          .multilineTextAlignment(.leading)
          .padding(EdgeInsets(top: 11, leading: 16, bottom: isLast ? 11 : 11 + 1, trailing: 16))
          .overlay(alignment: .bottom) {
            if !isLast { line }
          }
        }
      }
      .background(palette.surface)
      .clipShape(shape)
      .appShadows(palette.elevation, in: shape, scale: 1)
    }

    private var line: some View {
      Rectangle().fill(palette.rowLine).frame(height: 1)
    }
  }
#endif
