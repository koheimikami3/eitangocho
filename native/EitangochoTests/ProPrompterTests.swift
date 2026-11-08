import EitangochoData
import Foundation
import Testing

@testable import Eitangocho

/// 登録単語数が一定を超えた人に 1 回だけ出す Pro の案内の判定(ReviewPrompterTests と同じ組み方)。
@MainActor
final class ProPrompterTests {
  private let suiteName = "ProPrompterTests-\(UUID().uuidString)"
  private let defaults: UserDefaults
  private let database: AppDatabase
  private let analytics = FakeAnalyticsClient()
  private var canOffer = true
  private var presentCount = 0

  init() throws {
    defaults = UserDefaults(suiteName: suiteName)!
    database = try AppDatabase.inMemory()
  }

  deinit {
    UserDefaults().removePersistentDomain(forName: suiteName)
  }

  // 待ち時間は本番の値(1 秒)のままだとテストが遅くなるだけなので潰す。
  private func makePrompter() -> ProPrompter {
    ProPrompter(dao: database.wordDao, analytics: AnalyticsLogger(analytics), defaults: defaults, promptDelay: .zero) {
      [unowned self] in canOffer
    }
  }

  private func seedWords(_ count: Int, from start: Int = 0) async throws {
    for i in start..<(start + count) {
      try await database.wordDao.insertWord(NewWord(word: "word\(i)", meaning: "訳\(i)"))
    }
  }

  /// 保存直後の呼び出し。`presents` は案内を出せたか(ほかの表示が出ていれば false)。
  private func register(_ prompter: ProPrompter, presents: Bool = true) async {
    await prompter.onWordRegistered {
      guard presents else { return false }
      presentCount += 1
      return true
    }
  }

  @Test func 登録が30語に満たないうちは出さない() async throws {
    try await seedWords(29)
    await register(makePrompter())
    #expect(presentCount == 0)
  }

  @Test func 登録が30語になったら1回だけ出して記録する() async throws {
    try await seedWords(30)
    let prompter = makePrompter()

    await register(prompter)
    #expect(presentCount == 1)
    #expect(analytics.eventsNamed("pro_prompt_shown").count == 1)

    try await seedWords(1, from: 30)
    await register(prompter)
    #expect(presentCount == 1, "出した後は登録しても出さない")
  }

  @Test func すでに30語を超えている人にも次の登録で出す() async throws {
    try await seedWords(45)
    await register(makePrompter())
    #expect(presentCount == 1)
  }

  @Test func 購入の側の条件を満たさなければ出さず記録もしない() async throws {
    try await seedWords(30)
    let prompter = makePrompter()

    canOffer = false
    await register(prompter)
    #expect(presentCount == 0)

    canOffer = true
    await register(prompter)
    #expect(presentCount == 1, "購入できるようになった後の登録で出す")
  }

  @Test func ほかの表示で出せなかった回は記録せず次の登録で出す() async throws {
    try await seedWords(30)
    let prompter = makePrompter()

    await register(prompter, presents: false)
    #expect(analytics.eventsNamed("pro_prompt_shown").isEmpty)

    await register(prompter)
    #expect(presentCount == 1)
  }

  @Test func レビュー依頼の節目ちょうどでは出さず次の登録で出す() async throws {
    try await seedWords(50)
    let prompter = makePrompter()

    await register(prompter)
    #expect(presentCount == 0)

    try await seedWords(1, from: 50)
    await register(prompter)
    #expect(presentCount == 1)
  }

  @Test func 記録した番号が今の案内より古ければもう一度出す() async throws {
    try await seedWords(30)
    defaults.set(ProPromptConfig.campaign - 1, forKey: ProPrompter.shownCampaignKey)

    await register(makePrompter())
    #expect(presentCount == 1)
    #expect(defaults.integer(forKey: ProPrompter.shownCampaignKey) == ProPromptConfig.campaign)
  }
}
