import EitangochoData
import Foundation
import Testing

@testable import Eitangocho

/// Flutter 版の quiz_page_notifier_test.dart(計測の group は Phase 4 で移す)と、
/// quiz_view_shortcut_test.dart のキー操作の判定を移したもの。
@MainActor
struct QuizModelTests {
  private let database: AppDatabase

  init() throws {
    database = try AppDatabase.inMemory()
  }

  /// 学習済み単語を n 件入れ、それを出題元にしたモデルを返す。
  private func setupLearned(_ count: Int) async throws -> QuizModel {
    for i in 0..<count {
      let id = try await database.wordDao.insertWord(NewWord(word: "word\(i)", meaning: "訳\(i)"))
      try await database.wordDao.setLearned(id: id, true)
    }
    let learned = WordListing.learned(try await database.wordDao.getAll())
    return QuizModel(dao: database.wordDao) { learned }
  }

  @Test func startは学習済みから出題数分を選んで出題する() async throws {
    let model = try await setupLearned(quizQuestionCount + 1)
    model.start()
    #expect(model.phase == .active)
    #expect(model.questions.count == quizQuestionCount)
    #expect(model.index == 0)
    #expect(!model.revealed)
  }

  @Test func 学習済みが0件だとphaseがemptyになる() async throws {
    let model = try await setupLearned(0)
    model.start()
    #expect(model.phase == .empty)
  }

  @Test func answerKnewでindexが進みokCountが加算され最終問題でdoneになる() async throws {
    let model = try await setupLearned(2)
    model.start()

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
    model.start()
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
    model.start()
    model.reveal()
    #expect(model.revealed)
  }

  @Test func 始め直すと前の回の進み具合を消す() async throws {
    let model = try await setupLearned(3)
    model.start()
    model.reveal()
    await model.answerKnew()
    model.start()
    #expect(model.index == 0)
    #expect(model.okCount == 0)
    #expect(!model.revealed)
  }

  // MARK: - キー操作(quiz_view_shortcut_test)

  @Test(arguments: [QuizKey.space, .enter, .numpadEnter])
  func 開示前のSpaceとEnterで答えが開示される(key: QuizKey) async throws {
    let model = try await setupLearned(2)
    model.start()
    await model.handleKey(key)?.value
    #expect(model.revealed)
  }

  @Test(arguments: [QuizKey.rightArrow, .digit2])
  func 開示後の右矢印と2で覚えているとして次に進む(key: QuizKey) async throws {
    let model = try await setupLearned(2)
    model.start()
    model.reveal()
    await model.handleKey(key)?.value
    #expect(model.index == 1)
    #expect(model.okCount == 1)
    #expect(!model.revealed)
  }

  @Test(arguments: [QuizKey.leftArrow, .digit1])
  func 開示後の左矢印と1で忘れていたとして次に進む(key: QuizKey) async throws {
    let model = try await setupLearned(2)
    model.start()
    model.reveal()
    await model.handleKey(key)?.value
    #expect(model.index == 1)
    #expect(model.forgotWords.count == 1)
  }

  @Test func 開示前は左右の矢印が無反応() async throws {
    let model = try await setupLearned(2)
    model.start()
    #expect(model.handleKey(.leftArrow) == nil)
    #expect(model.handleKey(.rightArrow) == nil)
    #expect(model.index == 0)
    #expect(!model.revealed)
  }

  @Test func 開示後はSpaceを受け付けない() async throws {
    let model = try await setupLearned(2)
    model.start()
    model.reveal()
    #expect(model.handleKey(.space) == nil)
  }

  @Test func 回答の書き込み中は次の回答を受け付けない() async throws {
    let model = try await setupLearned(3)
    model.start()
    model.reveal()
    // キーリピートで同じ単語に二重に答えない。
    let first = model.handleKey(.rightArrow)
    let second = model.handleKey(.rightArrow)
    await first?.value
    await second?.value
    #expect(model.index == 1)
    #expect(model.okCount == 1)
  }
}
