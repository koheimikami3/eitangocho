import EitangochoData
import Foundation
import Testing

@testable import Eitangocho

/// Flutter 版の test/features/review/data/review_prompter_test.dart を移したもの。
/// 「openStoreListing は失敗しても例外を漏らさない」は移さない(Swift 版は設定画面が openURL で開き、投げないため)。
@MainActor
final class ReviewPrompterTests {
  private let suiteName = "ReviewPrompterTests-\(UUID().uuidString)"
  private let defaults: UserDefaults
  private let database: AppDatabase
  private let client = FakeReviewClient()
  private let analytics = FakeAnalyticsClient()

  init() throws {
    defaults = UserDefaults(suiteName: suiteName)!
    database = try AppDatabase.inMemory()
  }

  deinit {
    UserDefaults().removePersistentDomain(forName: suiteName)
  }

  // 待ち時間は本番の値(1 秒)のままだとテストが遅くなるだけなので潰す。
  private func makePrompter() -> ReviewPrompter {
    ReviewPrompter(
      client: client, dao: database.wordDao, analytics: AnalyticsLogger(analytics), defaults: defaults,
      promptDelay: .zero)
  }

  private func seedWords(_ count: Int) async throws {
    for i in 0..<count {
      try await database.wordDao.insertWord(NewWord(word: "word\(i)", meaning: "訳\(i)"))
    }
  }

  /// 前回の依頼日時を直接書き込む(ReviewPrompter のキーと同じもの)。
  private func setLastRequested(daysAgo days: Double) {
    let date = Date.now.addingTimeInterval(-days * 86_400)
    defaults.set(Int(date.timeIntervalSince1970 * 1000), forKey: "reviewLastRequestedAt")
  }

  /// 成績・出題数の条件を満たすセッションを times 回終える。
  private func completeGoodSessions(_ prompter: ReviewPrompter, _ times: Int) async {
    for _ in 0..<times {
      await prompter.onQuizCompleted(okCount: 5, total: 5)
    }
  }

  @Test func 条件をすべて満たすと3回目の完了で1回だけ依頼する() async throws {
    try await seedWords(20)
    let prompter = makePrompter()

    await completeGoodSessions(prompter, 2)
    #expect(client.requestCount == 0, "完了 2 回目までは出さない")

    await completeGoodSessions(prompter, 1)
    #expect(client.requestCount == 1)

    // 4 回目以降は間隔(120 日)に引っかかるので出さない。
    await completeGoodSessions(prompter, 1)
    #expect(client.requestCount == 1)
    #expect(analytics.eventsNamed("review_requested") == [["trigger": "quiz"]])
  }

  @Test func 出題数が少ないセッションでは依頼しない() async throws {
    try await seedWords(20)
    let prompter = makePrompter()
    for _ in 0..<5 {
      await prompter.onQuizCompleted(okCount: 4, total: 4)
    }
    #expect(client.requestCount == 0)
  }

  @Test func 成績が振るわないセッションでは依頼しない() async throws {
    try await seedWords(20)
    let prompter = makePrompter()
    for _ in 0..<5 {
      await prompter.onQuizCompleted(okCount: 2, total: 5)
    }
    #expect(client.requestCount == 0)
  }

  @Test func 登録単語が少ないうちは依頼しない() async throws {
    try await seedWords(19)
    await completeGoodSessions(makePrompter(), 5)
    #expect(client.requestCount == 0)
  }

  @Test func 条件を満たさない回も完了回数には数える() async throws {
    try await seedWords(20)
    let prompter = makePrompter()

    // 成績が悪い 2 回を挟んでも、3 回目の良いセッションで依頼が出る。
    await prompter.onQuizCompleted(okCount: 0, total: 5)
    await prompter.onQuizCompleted(okCount: 1, total: 5)
    await completeGoodSessions(prompter, 1)

    #expect(client.requestCount == 1)
    #expect(defaults.integer(forKey: "reviewQuizCompletedCount") == 3)
  }

  @Test func 前回の依頼から120日経っていなければ依頼しない() async throws {
    try await seedWords(20)
    setLastRequested(daysAgo: 119)
    await completeGoodSessions(makePrompter(), 3)
    #expect(client.requestCount == 0)
  }

  @Test func 前回の依頼から120日以上経っていれば再び依頼する() async throws {
    try await seedWords(20)
    setLastRequested(daysAgo: 121)
    await completeGoodSessions(makePrompter(), 3)
    #expect(client.requestCount == 1)
  }

  @Test func レビュー依頼を出せない端末では呼ばない() async throws {
    try await seedWords(20)
    client.isAvailable = false
    await completeGoodSessions(makePrompter(), 3)
    #expect(client.requestCount == 0)
    #expect(analytics.eventsNamed("review_requested").isEmpty)
  }

  @Test func 依頼が失敗しても記録しないので次回また試す() async throws {
    struct SDKError: Error {}
    try await seedWords(20)
    client.requestError = SDKError()
    let prompter = makePrompter()

    await completeGoodSessions(prompter, 3)
    #expect(client.requestCount == 1)

    // 前回の依頼日時が記録されていなければ、次のセッションでも試せる。
    await completeGoodSessions(prompter, 1)
    #expect(client.requestCount == 2)
  }

  // MARK: - 登録単語数の節目

  /// 1 語登録して onWordRegistered を呼ぶ(単語登録の保存と同じ順序)。
  private func register(_ prompter: ReviewPrompter, _ word: String) async throws {
    try await database.wordDao.insertWord(NewWord(word: word, meaning: "訳"))
    await prompter.onWordRegistered()
  }

  @Test func 五十語目の登録で依頼し前後の語数では出さない() async throws {
    try await seedWords(48)
    let prompter = makePrompter()

    try await register(prompter, "w49")
    #expect(client.requestCount == 0, "49 語目は節目ではない")

    try await register(prompter, "w50")
    #expect(client.requestCount == 1)

    try await register(prompter, "w51")
    #expect(client.requestCount == 1)
    #expect(analytics.eventsNamed("review_requested") == [["trigger": "word_milestone"]])
  }

  @Test func 百語目の登録でも依頼する() async throws {
    try await seedWords(99)
    try await register(makePrompter(), "w100")
    #expect(client.requestCount == 1)
  }

  @Test func 前回の依頼から120日経っていなければ節目でも依頼しない() async throws {
    try await seedWords(49)
    setLastRequested(daysAgo: 30)
    try await register(makePrompter(), "w50")
    #expect(client.requestCount == 0)
  }

  @Test func 節目での依頼も前回の依頼として記録しクイズ側の依頼を間隔で止める() async throws {
    try await seedWords(49)
    let prompter = makePrompter()

    try await register(prompter, "w50")
    await completeGoodSessions(prompter, 3)

    #expect(client.requestCount == 1)
  }
}
