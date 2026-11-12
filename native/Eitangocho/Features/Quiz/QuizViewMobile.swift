#if os(iOS)
  import EitangochoData
  import SwiftUI

  /// iOS 版のフラッシュクイズ(Flutter 版の QuizViewMobile)。
  ///
  /// 出題の進行は macOS 版と同じ `QuizModel` を共有し、見た目と操作(キー操作を持たない)だけが異なる。
  /// iOS は回が無いとき入口(出題元・問題数・向きを選ぶ。MobileQuizEntrance)を出す(2.18.0)。
  struct QuizViewMobile: View {
    let quiz: QuizModel
    let shell: MainShellModel
    let settings: SettingsStore
    /// 登録が 0 語のときの入口の「単語を登録」。登録シートを開く。
    let onRegister: () -> Void
    /// 結果の Pro への導線で設定を開く(先頭に Pro の欄がある)。
    let onOpenSettings: () -> Void

    @Environment(\.ads) private var ads
    @Environment(\.purchase) private var purchase
    @Environment(\.quizRectanglePreloader) private var rectanglePreloader
    @Environment(\.quizInterstitial) private var interstitial

    var body: some View {
      Group {
        if quiz.phase == .active, let word = quiz.current {
          // 出題中はスクロールさせず、カードを画面の高さいっぱいに広げる(長い中身はカードの中でスクロール)。
          MobileActiveQuiz(
            quiz: quiz, word: word, direction: settings.quizDirection, roundLabel: roundLabel, onAnswer: answer,
            onQuit: { quiz.showEntrance() }
          )
          .padding(20)
        } else {
          // 結果・空の案内は縦中央に置き、背が伸びたときはスクロールにする。入口は上に寄せる。
          // 中央に置くと、Pro の案内のダイアログでタブバー上のバナーが隠れて下の余白が変わったときに、
          // 入口全体が上下に動いてしまうため。
          let alignment: Alignment = quiz.phase == .entrance && quiz.hasAnyWords ? .top : .center
          GeometryReader { geometry in
            ScrollView {
              content
                .frame(maxWidth: .infinity, minHeight: max(geometry.size.height - 40, 0), alignment: alignment)
                .padding(20)
            }
          }
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
      case .empty, .entrance:
        MobileQuizEntrance(quiz: quiz, settings: settings, onRegister: onRegister)
      case .done:
        // インタースティシャルを出している間は、結果の画面(とそのレクタングル)を作らない。
        if interstitial?.isHoldingResult == true {
          MobileQuizAdNotice()
        } else {
          MobileQuizResultView(
            okCount: quiz.okCount, forgotWords: quiz.forgotWords, cycleNote: cycleNote,
            onRetry: { quiz.retryForgotten() }, onContinue: { quiz.continueRound() },
            onChangeConditions: { quiz.showEntrance() }, onOpenPro: onOpenSettings)
        }
      case .active:
        // 出題中は body で別に組む(スクロールさせないため)。
        EmptyView()
      }
    }

    /// 出題中の上に出す、何を出している回か(出題元と、全部なら一巡の進み具合)。
    private var roundLabel: String {
      switch quiz.round {
      case .retry: return String(localized: .quizSourceForgotten)
      case .source(let source, let count):
        let name = String(localized: source.label)
        guard count == .all, let progress = quiz.cycleProgress(source) else { return name }
        return name + " · " + String(localized: .quizCycleProgress(progress.done, progress.total))
      case nil: return ""
      }
    }

    /// 結果に出す一巡の案内(全部の回だけ)。一巡し終えたら「一巡しました」、途中なら進み具合。
    private var cycleNote: String? {
      guard case .source(let source, .all) = quiz.round else { return nil }
      if quiz.completedCycle { return String(localized: .quizCycleCompleted) }
      return quiz.cycleProgress(source).map { String(localized: .quizCycleProgress($0.done, $0.total)) }
    }

    /// 回答する。最後の問題なら、出せるインタースティシャルがあるときは結果の画面を待たせてから答え、
    /// 回が終わったら広告を出す(閉じると結果の画面になる)。
    private func answer(knew: Bool) {
      var holding = false
      // 初めてのクイズでは出さない(最初の体験を広告で邪魔しないため。QuizModel.isFirstEverRound)。
      if quiz.isOnLastQuestion, !quiz.isFirstEverRound, let interstitial, let purchase {
        holding = interstitial.holdResultIfReady(purchase: purchase)
      }
      Task {
        if knew { await quiz.answerKnew() } else { await quiz.answerForgot() }
        if holding { await interstitial?.present(roundFinished: quiz.phase == .done) }
      }
    }
  }

  /// 解き終えてからインタースティシャルが出るまでの案内。空の画面のまま急に広告が出ると、
  /// 押したものが効かなかったように見えるため、回るインジケーターと一言を出しておく。
  private struct MobileQuizAdNotice: View {
    @Environment(\.palette) private var palette

    var body: some View {
      VStack(spacing: 14) {
        MobileSpinner()
        AppText(.quizShowingAd, style: AppTextStyle(size: 14))
          .foregroundStyle(palette.textAlpha(50))
      }
    }
  }

  /// 出題中の進捗・カード・回答ボタン。
  private struct MobileActiveQuiz: View {
    let quiz: QuizModel
    let word: Word
    let direction: QuizDirection
    let roundLabel: String
    /// 回答(true = 覚えている)。最後の問題でインタースティシャルを挟むため、親が受け持つ。
    let onAnswer: (Bool) -> Void
    /// 上の × 。確認なしで入口に戻る(答えは 1 問ごとに記録済みで失われないため)。
    let onQuit: () -> Void

    @Environment(\.palette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
      // en→ja: 表面 = 英単語 + IPA、裏面 = 訳。ja→en: 表面 = 訳(IPA なし)、裏面 = 英単語。
      let isJaToEn = direction == .jaToEn
      VStack(spacing: 16) {
        VStack(spacing: 4) {
          HStack(spacing: 8) {
            AppText(roundLabel, style: AppTextStyle(size: 12))
              .lineLimit(1)
              .frame(maxWidth: .infinity, alignment: .leading)
            MobilePressable(action: onQuit) {
              Image(systemName: "xmark")
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
            }
            .accessibilityLabel(Text(.quizQuit))
          }
          // 残りの量を感覚で分からせる進捗のバー(試作)。数字はバーの横に添える。
          HStack(spacing: 10) {
            MobileQuizProgressBar(current: quiz.index + 1, total: quiz.questions.count)
            AppText("\(quiz.index + 1) / \(quiz.questions.count)", style: AppTextStyle(size: 12, weight: .w600))
              .monospacedDigit()
          }
        }
        .foregroundStyle(palette.textAlpha(45))
        // 次の問題へ移るとき、今のカードを山札から払うように左へ飛ばし、後ろのカードを手前に出す(2026-11-12 の試作)。
        // 問題ごとに別のカードとして作り直し(id)、飛んでいく前のカードを上に重ねる(zIndex)。
        ZStack {
          MobileQuizCard(
            front: isJaToEn ? word.meaning : word.word,
            ipa: isJaToEn ? "" : word.ipa,
            revealed: quiz.revealed,
            back: isJaToEn ? word.word : word.meaning,
            exampleEn: word.exampleEn,
            exampleTranslation: word.exampleTranslation,
            englishWord: word.word)
          .id(quiz.index)
          .zIndex(-Double(quiz.index))
          .transition(cardTransition)
        }
        .frame(maxHeight: .infinity)
        // 払う動きは、続けて答えるテンポを崩さない範囲でゆっくりめにする
        // (0.3 秒・0.55 秒では速すぎた。0.75 秒と見比べて 0.95 秒に決めた。2026-11-12 のユーザー判断)。
        .animation(reduceMotion ? .easeOut(duration: 0.2) : .smooth(duration: 0.95), value: quiz.index)
        // 答えの前後でボタンの段の高さを変えない(カードの大きさが変わらないように)。
        // 「答えを表示」は回答のボタンと同じ位置に重ね、下の一言は答えの前は透明にして場所だけ取る。
        VStack(spacing: 10) {
          ZStack {
            HStack(spacing: 10) {
              MobileSoftButton(
                label: String(localized: .quizForgot), color: palette.danger, background: palette.dangerSoftButton
              ) {
                onAnswer(false)
              }
              MobileFilledButton(label: String(localized: .quizRemembered), expands: true) {
                onAnswer(true)
              }
            }
            .opacity(quiz.revealed ? 1 : 0)
            .allowsHitTesting(quiz.revealed)
            if !quiz.revealed {
              // 単語が中央から上へ滑らかに上がり、答えがふわっと出るようにする(MobileQuizCard)。
              MobileFilledButton(label: String(localized: .showAnswer), expands: true) {
                withAnimation(reduceMotion ? nil : .smooth(duration: 0.3)) { quiz.reveal() }
              }
            }
          }
          AppText(.quizForgotHint, style: AppTextStyle(size: 11))
            .foregroundStyle(palette.textAlpha(38))
            .opacity(quiz.revealed ? 1 : 0)
        }
      }
      .multilineTextAlignment(.center)
    }

    /// カードの入れ替わり。今のカードは左へ傾きながら飛んで消え、次のカードは一回り小さい所から手前に出る。
    /// 「視差効果を減らす」の人には、その場でふわっと入れ替えるだけにする。
    private var cardTransition: AnyTransition {
      if reduceMotion { return .opacity }
      return .asymmetric(
        insertion: .scale(scale: 0.94),
        removal: .modifier(active: MobileQuizCardFlyOff(progress: 1), identity: MobileQuizCardFlyOff(progress: 0)))
    }
  }

  /// 払われるカードの位置。`progress` が 1 で、下端を軸に 10 度傾きながら左へ画面の外まで飛ぶ。
  /// 薄れさせずに見えたまま飛ばす(薄れると、払うというより消えるように見えたため)。
  /// 飛ぶ距離は、傾いた右下の角まで画面の外に出きる長さにする(途中で消えると切れて見えるため)。
  private struct MobileQuizCardFlyOff: ViewModifier {
    let progress: CGFloat

    func body(content: Content) -> some View {
      content
        .rotationEffect(.degrees(-10 * progress), anchor: .bottom)
        .offset(x: -480 * progress)
    }
  }

  /// 出題中の進捗のバー。今の問題番号の割合をアクセント色で塗る(最後の問題で満ちる)。
  /// 答えた数ではなく問題番号にするのは、横に添える「4 / 4」とバーの長さを食い違わせないため。
  private struct MobileQuizProgressBar: View {
    let current: Int
    let total: Int

    @Environment(\.palette) private var palette

    var body: some View {
      let ratio = total > 0 ? min(CGFloat(current) / CGFloat(total), 1) : 0
      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: 3).fill(palette.borderAlpha(10))
          RoundedRectangle(cornerRadius: 3).fill(palette.accent)
            .frame(width: geometry.size.width * ratio)
        }
      }
      .frame(height: 6)
      .animation(.easeOut(duration: 0.25), value: current)
      .accessibilityHidden(true)
    }
  }
#endif
