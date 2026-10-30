import EitangochoData
import Foundation
import Observation
import OSLog

/// クイズで受け付けるキー(Flutter 版の QuizView の CallbackShortcuts)。
enum QuizKey: Sendable {
  case space, enter, numpadEnter, leftArrow, rightArrow, digit1, digit2
}

/// フラッシュクイズの進行(Flutter 版の QuizPageNotifier と QuizPageState)。
///
/// アプリが生きている間 1 つを持ち続ける。クイズの画面への入口(サイドバー・結果の「続ける」)は
/// 必ず `start(trigger:)` を呼ぶので、入るたびに新しい回になる。
@Observable
final class QuizModel {
  /// セッションの局面。
  enum Phase: Sendable {
    case empty, active, done
  }

  private(set) var phase: Phase = .empty

  /// セッション開始時に学習済み単語から選んだ出題(selectQuizQuestions)のスナップショット。
  /// セッション中の学習済みの変更・編集・削除は進行に影響させない。
  private(set) var questions: [Word] = []
  private(set) var index = 0
  private(set) var revealed = false
  private(set) var okCount = 0
  private(set) var forgotWords: [Word] = []

  /// 回答を DB に書いている間か。キーの押しっぱなし(キーリピート)で同じ単語に
  /// 二重に答えないよう、書き終えて次の問題に進むまで次の回答を受け付けない。
  @ObservationIgnored private var answering = false

  @ObservationIgnored private let dao: WordDao
  @ObservationIgnored private let analytics: AnalyticsLogger
  @ObservationIgnored private let review: ReviewPrompter
  @ObservationIgnored private let learnedWords: () -> [Word]

  private static let logger = Logger(subsystem: "com.kohei.mikami.eitangocho", category: "quiz")

  /// `learnedWords` は出題元(学習済みの単語)。始めるたびに読む。
  init(dao: WordDao, analytics: AnalyticsLogger, review: ReviewPrompter, learnedWords: @escaping () -> [Word]) {
    self.dao = dao
    self.analytics = analytics
    self.review = review
    self.learnedWords = learnedWords
  }

  /// 出題中の単語。
  var current: Word? { phase == .active ? questions[index] : nil }

  /// 学習済み単語から 1 セッション分を選んで新しい回を始める(選び方は selectQuizQuestions)。
  /// 直前に答えた単語は日時が新しくなって後ろに回るため、「続ける」では次の単語が出る。
  /// `trigger` は計測用(どこから始めたか)。
  func start(trigger: QuizTrigger) {
    // 回の途中でサイドバーのクイズを押し直した場合も、前の回は離脱として数える。
    abandonIfActive()
    let questions = selectQuizQuestions(learnedWords())
    resetSession(questions, phase: questions.isEmpty ? .empty : .active)
    if questions.isEmpty {
      analytics.logQuizEmptyShown()
    } else {
      analytics.logQuizStarted(trigger: trigger, questions: questions)
    }
  }

  /// 表示中の画面が変わったとき。回の途中でクイズ以外の画面へ移ったら、離脱として計測する。
  /// クイズへの入口は必ず `start(trigger:)` を呼ぶので、戻ってきたときは新しい回になる。
  func viewChanged(from previous: MainView, to next: MainView) {
    if previous == .quiz && next != .quiz {
      abandonIfActive()
    }
  }

  /// 回の途中なら離脱を送り、状態を初期化する(同じ回を二重に数えない)。
  /// アプリを終了された回は検知できない。
  private func abandonIfActive() {
    guard phase == .active else { return }
    analytics.logQuizAbandoned(answeredCount: index)
    resetSession([], phase: .empty)
  }

  /// 回の状態を最初に戻し、`questions` を出題にする。
  private func resetSession(_ questions: [Word], phase: Phase) {
    self.questions = questions
    self.phase = phase
    index = 0
    revealed = false
    okCount = 0
    forgotWords = []
  }

  func reveal() {
    revealed = true
  }

  /// 「覚えている」: 実績を記録して次へ進む。
  func answerKnew() async {
    await answer(knew: true)
  }

  /// 「忘れていた」: 学習中に戻し、実績を記録して次へ進む。
  func answerForgot() async {
    await answer(knew: false)
  }

  /// キー操作。開示前は Space / Enter で答えを開き、開示後は ← / 1 で忘れていた、
  /// → / 2 で覚えている。受け付けたキーなら、その処理(回答は DB への書き込み)を返す。
  @discardableResult
  func handleKey(_ key: QuizKey) -> Task<Void, Never>? {
    guard phase == .active else { return nil }
    switch (revealed, key) {
    case (false, .space), (false, .enter), (false, .numpadEnter):
      reveal()
      return Task {}
    case (true, .leftArrow), (true, .digit1):
      return Task { await answerForgot() }
    case (true, .rightArrow), (true, .digit2):
      return Task { await answerKnew() }
    default:
      return nil
    }
  }

  private func answer(knew: Bool) async {
    guard let word = current, !answering else { return }
    answering = true
    defer { answering = false }
    do {
      if !knew {
        try await dao.setLearned(id: word.id, false)
      }
      try await dao.recordQuizResult(id: word.id, knew: knew)
    } catch {
      Self.logger.error("クイズの回答を記録できない: \(String(describing: error), privacy: .public)")
      return
    }
    advance(knew: knew, word: word)
  }

  private func advance(knew: Bool, word: Word) {
    let next = index + 1
    index = next
    revealed = false
    if knew {
      okCount += 1
    } else {
      forgotWords.append(word)
    }
    if next >= questions.count {
      phase = .done
      analytics.logQuizCompleted(okCount: okCount, forgotCount: forgotWords.count)
      // 最後まで終えた直後がクイズでのレビュー依頼の契機(条件は ReviewPrompter が判定し、
      // 満たさなければ何も起きない)。依頼の成否はクイズの進行に関係しないので待たない。
      let (okCount, total) = (okCount, questions.count)
      Task { await review.onQuizCompleted(okCount: okCount, total: total) }
    }
  }
}
