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
    let words = try await database.wordDao.getAll()
    return QuizModel(
      dao: database.wordDao, analytics: AnalyticsLogger(analytics), review: disabledReviewPrompter(dao: database.wordDao),
      currentWords: { words })
  }

  @Test func 学習済みの10問で始めると出題数分を選んで出題する() async throws {
    let model = try await setupLearned(QuizQuestionCount.ten.limit + 1)
    model.start(source: .learned, count: .ten, trigger: .tab)
    #expect(model.phase == .active)
    #expect(model.questions.count == QuizQuestionCount.ten.limit)
    #expect(model.index == 0)
    #expect(!model.revealed)
  }

  @Test func answerKnewでindexが進みokCountが加算され最終問題でdoneになる() async throws {
    let model = try await setupLearned(2)
    model.start(source: .learned, count: .ten, trigger: .tab)

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
    model.start(source: .learned, count: .ten, trigger: .tab)
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

  // MARK: - 回をほかの画面への切り替えをまたいで保つ

  /// 今ある単語を差し替えられる入れ物(戻ってきたときに読む `currentWords` の元)。
  private final class WordsBox {
    var words: [Word] = []
  }

  /// 学習済み単語を n 件入れ、今ある単語を差し替えられるモデルを返す。
  private func setupKeepingRound(_ count: Int) async throws -> (QuizModel, WordsBox) {
    for i in 0..<count {
      let id = try await database.wordDao.insertWord(NewWord(word: "word\(i)", meaning: "訳\(i)"))
      try await database.wordDao.setLearned(id: id, true)
    }
    let box = WordsBox()
    box.words = try await database.wordDao.getAll()
    let model = QuizModel(
      dao: database.wordDao, analytics: AnalyticsLogger(analytics), review: disabledReviewPrompter(dao: database.wordDao),
      currentWords: { box.words })
    return (model, box)
  }

  @Test func ほかの画面へ移って戻っても続きから出題する() async throws {
    let (model, _) = try await setupKeepingRound(3)
    model.start(source: .learned, count: .ten, trigger: .tab)
    await model.answerKnew()
    model.reveal()

    model.enterFromTab()

    #expect(model.phase == .active)
    #expect(model.index == 1)
    #expect(model.okCount == 1)
    #expect(model.revealed, "出題中の単語が変わっていなければ開示の状態も保つ")
    #expect(analytics.eventsNamed("quiz_started").count == 1)
  }

  @Test func 選んでいるタブを押し直してもやり直さない() async throws {
    let (model, _) = try await setupKeepingRound(3)
    model.start(source: .learned, count: .ten, trigger: .tab)
    await model.answerKnew()
    model.enterFromTab()
    #expect(model.index == 1)
    #expect(analytics.eventsNamed("quiz_started").count == 1)
  }

  @Test func 結果の画面のままでタブから入ってもやり直さない() async throws {
    let (model, _) = try await setupKeepingRound(1)
    model.start(source: .learned, count: .ten, trigger: .tab)
    await model.answerKnew()
    model.enterFromTab()
    #expect(model.phase == .done)
    #expect(model.okCount == 1)
  }

  @Test func 回が無いときにタブから入ると出題を始めずに入口を出す() async throws {
    let (model, _) = try await setupKeepingRound(3)
    model.enterFromTab()
    #expect(model.phase == .entrance)
    #expect(analytics.eventsNamed("quiz_started").isEmpty)
    #expect(analytics.eventsNamed("quiz_empty_shown").isEmpty)
  }

  @Test func 入口で選ばれている出題元が空ならquiz_empty_shownを送る() async throws {
    let (model, _) = try await setupKeepingRound(0)
    model.enterFromTab()
    #expect(model.phase == .entrance)
    #expect(analytics.eventsNamed("quiz_empty_shown").count == 1)
  }

  @Test func 離れている間の削除を残りの出題から外し編集を反映する() async throws {
    let (model, box) = try await setupKeepingRound(3)
    model.start(source: .learned, count: .ten, trigger: .tab)
    await model.answerKnew()
    let answered = model.questions[0]
    let deleted = model.questions[1]
    let edited = model.questions[2]
    model.reveal()

    try await database.wordDao.deleteWord(id: deleted.id)
    box.words = box.words.filter { $0.id != deleted.id }.map { word in
      var word = word
      if word.id == edited.id { word.meaning = "直した訳" }
      return word
    }
    model.enterFromTab()

    #expect(model.questions.map(\.id) == [answered.id, edited.id])
    #expect(model.current?.meaning == "直した訳")
    #expect(!model.revealed, "出題中の単語が消えたら次の単語は開示前から")
  }

  @Test func 離れている間に残りがすべて消えたらそこまでで回を終える() async throws {
    let (model, box) = try await setupKeepingRound(2)
    model.start(source: .learned, count: .ten, trigger: .tab)
    await model.answerKnew()
    let remaining = model.questions[1]
    box.words = box.words.filter { $0.id != remaining.id }

    model.enterFromTab()

    #expect(model.phase == .done)
    #expect(model.okCount == 1)
    #expect(analytics.eventsNamed("quiz_completed").count == 1)
  }

  @Test func revealでrevealedがtrueになる() async throws {
    let model = try await setupLearned(1)
    model.start(source: .learned, count: .ten, trigger: .tab)
    model.reveal()
    #expect(model.revealed)
  }

  @Test func 始め直すと前の回の進み具合を消す() async throws {
    let model = try await setupLearned(3)
    model.start(source: .learned, count: .ten, trigger: .tab)
    model.reveal()
    await model.answerKnew()
    model.start(source: .learned, count: .ten, trigger: .tab)
    #expect(model.index == 0)
    #expect(model.okCount == 0)
    #expect(!model.revealed)
  }

  // MARK: - キー操作(quiz_view_shortcut_test)

  @Test(arguments: [QuizKey.space, .enter, .numpadEnter])
  func 開示前のSpaceとEnterで答えが開示される(key: QuizKey) async throws {
    let model = try await setupLearned(2)
    model.start(source: .learned, count: .ten, trigger: .tab)
    await model.handleKey(key)?.value
    #expect(model.revealed)
  }

  @Test(arguments: [QuizKey.rightArrow, .digit2])
  func 開示後の右矢印と2で覚えているとして次に進む(key: QuizKey) async throws {
    let model = try await setupLearned(2)
    model.start(source: .learned, count: .ten, trigger: .tab)
    model.reveal()
    await model.handleKey(key)?.value
    #expect(model.index == 1)
    #expect(model.okCount == 1)
    #expect(!model.revealed)
  }

  @Test(arguments: [QuizKey.leftArrow, .digit1])
  func 開示後の左矢印と1で忘れていたとして次に進む(key: QuizKey) async throws {
    let model = try await setupLearned(2)
    model.start(source: .learned, count: .ten, trigger: .tab)
    model.reveal()
    await model.handleKey(key)?.value
    #expect(model.index == 1)
    #expect(model.forgotWords.count == 1)
  }

  @Test func 開示前は左右の矢印が無反応() async throws {
    let model = try await setupLearned(2)
    model.start(source: .learned, count: .ten, trigger: .tab)
    #expect(model.handleKey(.leftArrow) == nil)
    #expect(model.handleKey(.rightArrow) == nil)
    #expect(model.index == 0)
    #expect(!model.revealed)
  }

  @Test func 開示後はSpaceを受け付けない() async throws {
    let model = try await setupLearned(2)
    model.start(source: .learned, count: .ten, trigger: .tab)
    model.reveal()
    #expect(model.handleKey(.space) == nil)
  }

  @Test func 回答の書き込み中は次の回答を受け付けない() async throws {
    let model = try await setupLearned(3)
    model.start(source: .learned, count: .ten, trigger: .tab)
    model.reveal()
    // キーリピートで同じ単語に二重に答えない。
    let first = model.handleKey(.rightArrow)
    let second = model.handleKey(.rightArrow)
    await first?.value
    await second?.value
    #expect(model.index == 1)
    #expect(model.okCount == 1)
  }

  @Test func 回答の書き込み中に入口へ戻ったら書き終えても回を進めない() async throws {
    let model = try await setupLearned(1)
    model.start(source: .learned, count: .ten, trigger: .tab)
    model.reveal()
    // 回答を DB への書き込みで待たせている間に × で入口へ戻る。
    let resume = holdDatabase(database)
    let answer = model.handleKey(.rightArrow)
    try await letTasksReachDatabase()
    model.showEntrance()
    resume()
    await answer?.value

    #expect(model.phase == .entrance)
    #expect(analytics.eventsNamed("quiz_completed").isEmpty)
    // 答えた記録そのものは残す。
    #expect(try await database.wordDao.getAll().first?.lastReviewedAt != nil)
  }

  @Test func 回答の書き込み中に始め直したら新しい回を進めない() async throws {
    let model = try await setupLearned(3)
    model.start(source: .learned, count: .ten, trigger: .tab)
    model.reveal()
    let resume = holdDatabase(database)
    let answer = model.handleKey(.rightArrow)
    try await letTasksReachDatabase()
    model.start(source: .learned, count: .ten, trigger: .tab)
    resume()
    await answer?.value

    #expect(model.phase == .active)
    #expect(model.index == 0)
    #expect(model.okCount == 0)
  }

  // MARK: - 計測

  @Test func 始めた契機と最後まで答えた結果を送る() async throws {
    let model = try await setupLearned(2)
    model.start(source: .learned, count: .ten, trigger: .continued)
    await model.answerKnew()
    await model.answerForgot()

    // 投入したばかりの単語は一度も答えていない。
    #expect(
      analytics.eventsNamed("quiz_started") == [
        ["trigger": "continue", "review_gap_bucket": "0_none", "source": "learned", "question_count": "10"]
      ])
    #expect(analytics.eventsNamed("quiz_completed") == [["ok_count": 1, "forgot_count": 1]])
  }

  // MARK: - 入口の出題元・問題数

  private let suiteName = "QuizModelTests-\(UUID().uuidString)"

  private func makeSettings() -> SettingsStore {
    SettingsStore(defaults: UserDefaults(suiteName: suiteName)!, preferredLanguages: ["ja"])
  }

  /// 学習中 `learning` 語・学習済み `learned` 語(先頭 `bookmarked` 語にブックマーク)を入れ、
  /// 入口の条件を保存するモデルを返す。
  private func setupEntrance(learning: Int, learned: Int, bookmarked: Int = 0) async throws
    -> (QuizModel, WordsBox, SettingsStore)
  {
    for i in 0..<(learning + learned) {
      let id = try await database.wordDao.insertWord(NewWord(word: "word\(i)", meaning: "訳\(i)"))
      if i >= learning { try await database.wordDao.setLearned(id: id, true) }
      if i < bookmarked { try await database.wordDao.setBookmarked(id: id, true) }
    }
    let box = WordsBox()
    box.words = try await database.wordDao.getAll()
    let settings = makeSettings()
    let model = QuizModel(
      dao: database.wordDao, analytics: AnalyticsLogger(analytics), review: disabledReviewPrompter(dao: database.wordDao),
      settings: settings, currentWords: { box.words })
    return (model, box, settings)
  }

  @Test func 出題元の既定は学習済みがあれば学習済み() async throws {
    let (model, _, _) = try await setupEntrance(learning: 2, learned: 1)
    #expect(model.entranceSource(proUnlocked: false) == .learned)
  }

  @Test func 出題元の既定は学習済みが無ければ学習中() async throws {
    let (model, _, _) = try await setupEntrance(learning: 2, learned: 0)
    #expect(model.entranceSource(proUnlocked: false) == .learning)
  }

  @Test func Proでなければ保存したPro向けの出題元と問題数を無料のものに戻して見せる() async throws {
    let (model, _, settings) = try await setupEntrance(learning: 2, learned: 1)
    settings.setQuizSource(.bookmarks)
    settings.setQuizQuestionCount(.fifty)
    #expect(model.entranceSource(proUnlocked: false) == .learned)
    #expect(model.entranceCount(proUnlocked: false) == .ten)
    #expect(model.entranceSource(proUnlocked: true) == .bookmarks)
    #expect(model.entranceCount(proUnlocked: true) == .fifty)
    // 購入状態がまだ分からない間は保存した値のまま(Pro の人が読み込み前に始めても条件が戻らないように)。
    #expect(model.entranceSource(proUnlocked: nil) == .bookmarks)
    #expect(model.entranceCount(proUnlocked: nil) == .fifty)
    // 保存した値は消さない(買い直したら戻る)。
    #expect(settings.quizSource == .bookmarks)
  }

  @Test(arguments: [
    (QuizSource.learning, 3), (QuizSource.learned, 2), (QuizSource.bookmarks, 1), (QuizSource.all, 5),
  ])
  func 出題元の単語から出題し選んだ条件を覚える(source: QuizSource, expected: Int) async throws {
    let (model, box, settings) = try await setupEntrance(learning: 3, learned: 2, bookmarked: 1)
    #expect(model.wordCount(source) == expected)
    model.start(source: source, count: .ten, trigger: .tab)
    #expect(model.phase == .active)
    #expect(model.round == .source(source, .ten))
    #expect(Set(model.questions.map(\.id)) == Set(source.words(from: box.words).map(\.id)))
    #expect(settings.quizSource == source)
  }

  @Test func 出題元が空なら始めずに入口のままにする() async throws {
    let (model, _, _) = try await setupEntrance(learning: 2, learned: 0)
    model.start(source: .learned, count: .ten, trigger: .tab)
    #expect(model.phase == .entrance)
    #expect(analytics.eventsNamed("quiz_started").isEmpty)
  }

  @Test func 開始ボタンの数は出せる数と問題数の小さい方() async throws {
    let (model, _, _) = try await setupEntrance(learning: 7, learned: 60)
    #expect(model.availableCount(source: .learning, count: .ten) == 7)
    #expect(model.availableCount(source: .learned, count: .ten) == 10)
    #expect(model.availableCount(source: .learned, count: .thirty) == 30)
    #expect(model.availableCount(source: .learned, count: .fifty) == 50)
    #expect(model.availableCount(source: .learned, count: .all) == 50)
  }

  @Test func 全部は50問ずつ一巡し一巡を終えたら最初から() async throws {
    let (model, box, _) = try await setupEntrance(learning: 0, learned: 60)
    // 始めたのと同じ秒のうちに答えた分も、一巡で答えた数に入る(前回出題日は DB に秒で入る)。
    model.start(source: .learned, count: .all, trigger: .tab)
    #expect(model.questions.count == 50)
    for _ in 0..<50 { await model.answerKnew() }
    box.words = try await database.wordDao.getAll()
    #expect(model.phase == .done)
    #expect(model.cycleProgress(.learned).map { [$0.done, $0.total] } == [50, 60])
    #expect(!model.completedCycle)

    // 続きは一巡で残っている 10 語。
    model.continueRound()
    #expect(model.questions.count == 10)
    let firstChunk = Set(try await database.wordDao.getAll().filter { $0.lastReviewedAt != nil }.map(\.id))
    #expect(firstChunk.isDisjoint(with: model.questions.map(\.id)))
    for _ in 0..<10 { await model.answerKnew() }
    box.words = try await database.wordDao.getAll()
    #expect(model.completedCycle)

    // 一巡を終えた後は最初から(出題元の全体から 50 問)。答え終えてすぐ(同じ秒のうちに)始め直しても、
    // 前の一巡の回答は新しい一巡に数えない。
    model.continueRound()
    #expect(model.questions.count == 50)
    #expect(model.cycleProgress(.learned).map { [$0.done, $0.total] } == [0, 60])
  }

  @Test func 全部で1語を始めてすぐ答えても一巡を終えたことになる() async throws {
    let (model, box, _) = try await setupEntrance(learning: 0, learned: 1)
    model.start(source: .learned, count: .all, trigger: .tab)
    await model.answerKnew()
    box.words = try await database.wordDao.getAll()
    #expect(model.cycleProgress(.learned).map { [$0.done, $0.total] } == [1, 1])
    #expect(model.completedCycle)
  }

  @Test func 忘れた単語だけもう一度の後の続けるは元の出題元へ戻る() async throws {
    let (model, box, _) = try await setupEntrance(learning: 0, learned: 3)
    model.start(source: .learned, count: .ten, trigger: .tab)
    await model.answerForgot()
    await model.answerKnew()
    await model.answerForgot()
    let forgot = Set(model.forgotWords.map(\.id))
    box.words = try await database.wordDao.getAll()

    model.retryForgotten()
    #expect(model.round == .retry)
    #expect(Set(model.questions.map(\.id)) == forgot)

    await model.answerKnew()
    await model.answerKnew()
    model.continueRound()
    #expect(model.round == .source(.learned, .ten))
    let started = analytics.eventsNamed("quiz_started")
    #expect(started.map { $0["source"] as? String } == ["learned", "forgotten", "learned"])
    #expect(started[1]["trigger"] as? String == "retry")
    #expect(started[1]["question_count"] == nil)
  }

  @Test func どの単語もまだ出題していない回だけ初めてのクイズとする() async throws {
    let (model, box, _) = try await setupEntrance(learning: 2, learned: 0)
    model.start(source: .learning, count: .ten, trigger: .tab)
    #expect(model.isFirstEverRound)
    await model.answerKnew()
    await model.answerKnew()
    box.words = try await database.wordDao.getAll()
    model.continueRound()
    #expect(!model.isFirstEverRound)
  }

  @Test func showEntranceで回を捨てて入口に戻る() async throws {
    let (model, _, _) = try await setupEntrance(learning: 3, learned: 0)
    model.start(source: .learning, count: .ten, trigger: .tab)
    await model.answerKnew()
    model.showEntrance()
    #expect(model.phase == .entrance)
    #expect(model.round == nil)
    #expect(model.questions.isEmpty)
  }
}
