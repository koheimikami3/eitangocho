import EitangochoData
import Foundation
import Testing

@testable import Eitangocho

/// Flutter 版の quiz_page_notifier_test.dart と、quiz_view_shortcut_test.dart のキー操作の判定を移したもの。
@MainActor
struct QuizModelTests {
  private let database: AppDatabase

  init() throws {
    database = try AppDatabase.inMemory()
  }

  private let analytics = FakeAnalyticsClient()

  /// 学習済み単語を n 件入れ、それを出題元にしたモデルを返す。
  private func setupLearned(_ count: Int) async throws -> QuizModel {
    for i in 0..<count {
      let id = try await database.wordDao.insertWord(NewWord(word: "word\(i)", meaning: "訳\(i)"))
      try await database.wordDao.setLearned(id: id, true)
    }
    let learned = WordListing.learned(try await database.wordDao.getAll())
    return QuizModel(
      dao: database.wordDao, analytics: AnalyticsLogger(analytics), review: disabledReviewPrompter(dao: database.wordDao)
    ) { learned }
  }

  @Test func startは学習済みから出題数分を選んで出題する() async throws {
    let model = try await setupLearned(quizQuestionCount + 1)
    model.start(trigger: .tab)
    #expect(model.phase == .active)
    #expect(model.questions.count == quizQuestionCount)
    #expect(model.index == 0)
    #expect(!model.revealed)
  }

  @Test func 学習済みが0件だとphaseがemptyになる() async throws {
    let model = try await setupLearned(0)
    model.start(trigger: .tab)
    #expect(model.phase == .empty)
  }

  @Test func answerKnewでindexが進みokCountが加算され最終問題でdoneになる() async throws {
    let model = try await setupLearned(2)
    model.start(trigger: .tab)

    await model.answerKnew()
    #expect(model.index == 1)
    #expect(model.okCount == 1)
    #expect(model.phase == .active)

    await model.answerKnew()
    #expect(model.okCount == 2)
    #expect(model.phase == .done)
    #expect(model.forgotWords.isEmpty)
  }

  @Test func answerForgotで単語が学習中に戻りforgotWordsに追加される() async throws {
    let model = try await setupLearned(1)
    model.start(trigger: .tab)
    let target = try #require(model.questions.first)

    await model.answerForgot()

    // DB 上で学習中(isLearned = false)に戻っている。
    let word = try #require(try await database.wordDao.getAll().first)
    #expect(!word.isLearned)
    #expect(word.lastReviewedAt != nil)
    #expect(model.phase == .done)
    #expect(model.okCount == 0)
    #expect(model.forgotWords.map(\.id) == [target.id])
  }

  @Test func revealでrevealedがtrueになる() async throws {
    let model = try await setupLearned(1)
    model.start(trigger: .tab)
    model.reveal()
    #expect(model.revealed)
  }

  @Test func 始め直すと前の回の進み具合を消す() async throws {
    let model = try await setupLearned(3)
    model.start(trigger: .tab)
    model.reveal()
    await model.answerKnew()
    model.start(trigger: .tab)
    #expect(model.index == 0)
    #expect(model.okCount == 0)
    #expect(!model.revealed)
  }

  // MARK: - キー操作(quiz_view_shortcut_test)

  @Test(arguments: [QuizKey.space, .enter, .numpadEnter])
  func 開示前のSpaceとEnterで答えが開示される(key: QuizKey) async throws {
    let model = try await setupLearned(2)
    model.start(trigger: .tab)
    await model.handleKey(key)?.value
    #expect(model.revealed)
  }

  @Test(arguments: [QuizKey.rightArrow, .digit2])
  func 開示後の右矢印と2で覚えているとして次に進む(key: QuizKey) async throws {
    let model = try await setupLearned(2)
    model.start(trigger: .tab)
    model.reveal()
    await model.handleKey(key)?.value
    #expect(model.index == 1)
    #expect(model.okCount == 1)
    #expect(!model.revealed)
  }

  @Test(arguments: [QuizKey.leftArrow, .digit1])
  func 開示後の左矢印と1で忘れていたとして次に進む(key: QuizKey) async throws {
    let model = try await setupLearned(2)
    model.start(trigger: .tab)
    model.reveal()
    await model.handleKey(key)?.value
    #expect(model.index == 1)
    #expect(model.forgotWords.count == 1)
  }

  @Test func 開示前は左右の矢印が無反応() async throws {
    let model = try await setupLearned(2)
    model.start(trigger: .tab)
    #expect(model.handleKey(.leftArrow) == nil)
    #expect(model.handleKey(.rightArrow) == nil)
    #expect(model.index == 0)
    #expect(!model.revealed)
  }

  @Test func 開示後はSpaceを受け付けない() async throws {
    let model = try await setupLearned(2)
    model.start(trigger: .tab)
    model.reveal()
    #expect(model.handleKey(.space) == nil)
  }

  @Test func 回答の書き込み中は次の回答を受け付けない() async throws {
    let model = try await setupLearned(3)
    model.start(trigger: .tab)
    model.reveal()
    // キーリピートで同じ単語に二重に答えない。
    let first = model.handleKey(.rightArrow)
    let second = model.handleKey(.rightArrow)
    await first?.value
    await second?.value
    #expect(model.index == 1)
    #expect(model.okCount == 1)
  }

  // MARK: - 計測

  @Test func 始めた契機と最後まで答えた結果を送る() async throws {
    let model = try await setupLearned(2)
    model.start(trigger: .continued)
    await model.answerKnew()
    await model.answerForgot()

    // 投入したばかりの単語は一度も答えていない。
    #expect(analytics.eventsNamed("quiz_started") == [["trigger": "continue", "review_gap_bucket": "0_none"]])
    #expect(analytics.eventsNamed("quiz_completed") == [["ok_count": 1, "forgot_count": 1]])
    #expect(analytics.eventsNamed("quiz_abandoned").isEmpty)
  }

  @Test func 学習済みが0件ならquiz_empty_shownだけを送る() async throws {
    let model = try await setupLearned(0)
    model.start(trigger: .tab)
    #expect(analytics.eventsNamed("quiz_empty_shown").count == 1)
    #expect(analytics.eventsNamed("quiz_started").isEmpty)
  }

  @Test func 回の途中で別の画面へ移ると答えた数を付けて離脱を1回だけ送る() async throws {
    let model = try await setupLearned(3)
    model.start(trigger: .tab)
    model.viewChanged(from: .learning, to: .quiz)
    await model.answerKnew()

    model.viewChanged(from: .quiz, to: .learning)
    // 戻ってきて新しい回を始めても、前の回を二重に数えない。
    model.start(trigger: .tab)
    model.viewChanged(from: .learning, to: .quiz)

    #expect(analytics.eventsNamed("quiz_abandoned") == [["answered_count": 1]])
  }

  @Test func 回の途中でクイズを押し直しても離脱として送る() async throws {
    let model = try await setupLearned(3)
    model.start(trigger: .tab)
    model.start(trigger: .tab)
    #expect(model.phase == .active)
    #expect(analytics.eventsNamed("quiz_abandoned") == [["answered_count": 0]])
  }

  @Test func 最後まで答えた回は画面を移っても離脱にしない() async throws {
    let model = try await setupLearned(1)
    model.start(trigger: .tab)
    model.viewChanged(from: .learning, to: .quiz)
    await model.answerKnew()

    model.viewChanged(from: .quiz, to: .learning)

    #expect(analytics.eventsNamed("quiz_abandoned").isEmpty)
  }
}
