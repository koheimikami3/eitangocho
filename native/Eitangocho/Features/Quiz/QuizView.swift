#if os(macOS)
  import EitangochoData
  import SwiftUI

  /// macOS 版のフラッシュクイズの画面(Flutter 版の QuizView)。局面で入口 / 出題 / 結果を出し分ける(入口は 2.18.0 から)。
  /// 出題方向は設定 quizDirection に従う(ja→en のときは表面 = 訳・裏面 = 英単語・IPA なし)。
  struct QuizView: View {
    let quiz: QuizModel
    let settings: SettingsStore
    /// 登録が 0 語のときの入口の「単語を登録」。
    let onRegister: () -> Void

    @Environment(\.uiScale) private var px

    var body: some View {
      // プロトタイプ準拠で画面全体の縦横中央に置く。中身が画面より高いとき
      // (答えの表示 + 長い例文など)はスクロールにする。
      GeometryReader { geometry in
        ScrollView {
          content
            .frame(maxWidth: px(480))
            .frame(maxWidth: .infinity, minHeight: max(geometry.size.height - px(40), 0))
            .padding(px(20))
        }
      }
    }

    @ViewBuilder
    private var content: some View {
      switch quiz.phase {
      case .entrance:
        QuizEntrance(quiz: quiz, settings: settings, onRegister: onRegister)
      case .done:
        QuizResultView(
          okCount: quiz.okCount, forgotWords: quiz.forgotWords, cycleNote: quiz.cycleNote,
          onRetry: { quiz.retryForgotten() }, onContinue: { quiz.continueRound() },
          onChangeConditions: { quiz.showEntrance() })
      case .active:
        if let word = quiz.current {
          ActiveQuiz(quiz: quiz, word: word, direction: settings.quizDirection)
        }
      }
    }
  }

  /// 出題中の回の案内・カード・回答ボタン。キー操作はここで受ける(Flutter 版の CallbackShortcuts + autofocus)。
  private struct ActiveQuiz: View {
    let quiz: QuizModel
    let word: Word
    let direction: QuizDirection

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    @FocusState private var focused: Bool

    var body: some View {
      // en→ja: 表面 = 英単語 + IPA、裏面 = 訳。ja→en: 表面 = 訳(IPA なし)、裏面 = 英単語。
      let isJaToEn = direction == .jaToEn
      VStack(spacing: 0) {
        header
        Spacer().frame(height: px(12))
        QuizCard(
          front: isJaToEn ? word.meaning : word.word,
          ipa: isJaToEn ? "" : word.ipa,
          revealed: quiz.revealed,
          back: isJaToEn ? word.word : word.meaning,
          exampleEn: word.exampleEn,
          exampleTranslation: word.exampleTranslation,
          englishWord: word.word,
          pronunciationOnFront: !isJaToEn,
          onReveal: { quiz.reveal() })
        if quiz.revealed {
          Spacer().frame(height: px(16))
          QuizAnswerButtons(
            onForgot: { Task { await quiz.answerForgot() } },
            onKnew: { Task { await quiz.answerKnew() } })
        }
      }
      .focusable()
      .focused($focused)
      // キーを受けるためだけの焦点なので、焦点の枠は出さない。
      .focusEffectDisabled()
      .onKeyPress(phases: .down) { press in
        guard let key = QuizKey(press), quiz.handleKey(key) != nil else { return .ignored }
        return .handled
      }
      // Esc は × と同じく入口に戻る。
      .onExitCommand { quiz.showEntrance() }
      // 画面に入ったとき(入口・「続ける」から始めたとき)にすぐキーを受けられるようにする。
      .onAppear { focused = true }
    }

    /// 何を出している回か(出題元と、全部なら一巡の進み具合)・何問目か・入口へ戻る ×。
    /// × は確認なしで入口に戻す(答えは 1 問ごとに記録済みで失われないため。iOS と同じ)。
    private var header: some View {
      HStack(spacing: px(8)) {
        AppText(quiz.roundLabel, style: AppTextStyle(size: 12))
          .lineLimit(1)
          .frame(maxWidth: .infinity, alignment: .leading)
        AppText("\(quiz.index + 1) / \(quiz.questions.count)", style: AppTextStyle(size: 12, weight: .w600))
          .monospacedDigit()
        QuizQuitButton { quiz.showEntrance() }
      }
      .foregroundStyle(colors.textTertiary)
    }
  }

  /// 出題中の右上の ×(入口へ戻る)。ホバーで地を敷き、押せることを分からせる。
  private struct QuizQuitButton: View {
    let action: () -> Void

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    @State private var isHovered = false

    var body: some View {
      let shape = RoundedRectangle(cornerRadius: px(6))
      Image(systemName: "xmark")
        .font(.system(size: px(11), weight: .semibold))
        .foregroundStyle(isHovered ? colors.textSecondary : colors.textTertiary)
        .frame(width: px(24), height: px(24))
        .background(shape.fill(isHovered ? colors.rowHoverBackground : .clear))
        .hoverTap($isHovered, in: shape, action: action)
        .pointerStyle(.link)
        .help(Text(.quizQuit))
        .accessibilityLabel(Text(.quizQuit))
        .accessibilityAddTraits(.isButton)
    }
  }

  extension QuizKey {
    /// 押されたキーをクイズのキーに読み替える。修飾キー付きは受けない(Flutter の SingleActivator と同じ)。
    fileprivate init?(_ press: KeyPress) {
      guard press.modifiers.isDisjoint(with: [.command, .control, .option, .shift]) else { return nil }
      switch press.key {
      case .space: self = .space
      case .return: self = .enter
      // テンキーの Enter は Return と別の文字(ETX)で届く。
      case KeyEquivalent("\u{03}"): self = .numpadEnter
      case .leftArrow: self = .leftArrow
      case .rightArrow: self = .rightArrow
      case "1": self = .digit1
      case "2": self = .digit2
      default: return nil
      }
    }
  }
#endif
