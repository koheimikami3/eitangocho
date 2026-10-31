import EitangochoData
import SwiftUI

/// フラッシュクイズの画面(Flutter 版の QuizView)。局面で空の状態 / 出題 / 結果を出し分ける。
/// 出題方向は設定 quizDirection に従う(ja→en のときは表面 = 訳・裏面 = 英単語・IPA なし)。
struct QuizView: View {
  let quiz: QuizModel
  let shell: MainShellModel
  let settings: SettingsStore

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
    case .empty:
      QuizEmptyState { shell.selectView(.learning) }
    case .done:
      QuizResultView(
        okCount: quiz.okCount, forgotWords: quiz.forgotWords,
        onContinue: { quiz.start(trigger: .continued) }, onToLearning: { shell.selectView(.learning) })
    case .active:
      if let word = quiz.current {
        ActiveQuiz(quiz: quiz, word: word, direction: settings.quizDirection)
      }
    }
  }
}

/// 出題中のカードと回答ボタン。キー操作はここで受ける(Flutter 版の CallbackShortcuts + autofocus)。
private struct ActiveQuiz: View {
  let quiz: QuizModel
  let word: Word
  let direction: QuizDirection

  @Environment(\.uiScale) private var px
  @FocusState private var focused: Bool

  var body: some View {
    // en→ja: 表面 = 英単語 + IPA、裏面 = 訳。ja→en: 表面 = 訳(IPA なし)、裏面 = 英単語。
    let isJaToEn = direction == .jaToEn
    VStack(spacing: 0) {
      QuizCard(
        progress: "\(quiz.index + 1) / \(quiz.questions.count)",
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
    // 画面に入ったとき(サイドバー・「続ける」から始めたとき)にすぐキーを受けられるようにする。
    .onAppear { focused = true }
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
