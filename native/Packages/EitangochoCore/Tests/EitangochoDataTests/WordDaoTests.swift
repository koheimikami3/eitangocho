import Foundation
import GRDB
import Testing

@testable import EitangochoData

/// Flutter 版の test/db/word_dao_test.dart の移植。
struct WordDaoTests {
  let database: AppDatabase
  var dao: WordDao { database.wordDao }

  init() throws {
    database = try AppDatabase.inMemory()
  }

  private func apple(_ word: String = "apple", _ meaning: String = "りんご") -> NewWord {
    NewWord(word: word, meaning: meaning)
  }

  private func firstEmission() async throws -> [Word] {
    for try await words in dao.observeAll() { return words }
    return []
  }

  @Test("insertWord は createdAt/updatedAt を付与し observeAll に反映される")
  func insertAddsTimestamps() async throws {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    let id = try await dao.insertWord(apple(), now: now)

    let words = try await firstEmission()
    #expect(words.count == 1)
    #expect(words.first?.id == id)
    #expect(words.first?.word == "apple")
    #expect(words.first?.createdAt == now)
    #expect(words.first?.updatedAt == now)
  }

  @Test("日時は秒に切り捨てて保存する(drift と同じ精度)")
  func truncatesToSeconds() async throws {
    try await dao.insertWord(apple(), now: Date(timeIntervalSince1970: 1_700_000_000.9))

    let word = try #require(try await dao.getAll().first)
    #expect(word.createdAt == Date(timeIntervalSince1970: 1_700_000_000))
    let raw = try await database.writer.read { db -> (String?, Int64?) in
      let row = try Row.fetchOne(db, sql: "SELECT created_at, typeof(created_at) AS type FROM words")
      return (row?["type"], row?["created_at"])
    }
    #expect(raw.0 == "integer")
    #expect(raw.1 == 1_700_000_000)
  }

  @Test("observeAll は登録日時の新しい順(同時刻は id の新しい順)で返す")
  func ordersByNewest() async throws {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    try await dao.insertWord(apple("first", "一つ目"), now: now)
    try await dao.insertWord(apple("second", "二つ目"), now: now)
    try await dao.insertWord(apple("older", "古い"), now: now.addingTimeInterval(-10))

    #expect(try await firstEmission().map(\.word) == ["second", "first", "older"])
  }

  @Test("countWords は登録件数を返し、削除に追従する")
  func countsWords() async throws {
    #expect(try await dao.countWords() == 0)

    let id = try await dao.insertWord(apple())
    try await dao.insertWord(apple("banana", "バナナ"))
    #expect(try await dao.countWords() == 2)

    try await dao.deleteWord(id: id)
    #expect(try await dao.countWords() == 1)
  }

  @Test("updateWord はフィールドと updatedAt を更新する")
  func updatesFields() async throws {
    let created = Date(timeIntervalSince1970: 1_700_000_000)
    let id = try await dao.insertWord(apple(), now: created)

    try await dao.updateWord(
      id: id,
      WordEdit(
        word: "apple", meaning: "リンゴ", ipa: "", partsOfSpeech: [.noun], exampleEn: "",
        exampleTranslation: ""),
      now: created.addingTimeInterval(1))

    let word = try #require(try await dao.getAll().first)
    #expect(word.meaning == "リンゴ")
    #expect(word.partsOfSpeech == [.noun])
    #expect(word.updatedAt > created)
    #expect(word.createdAt == created)
  }

  private func rename(_ id: Int64, to word: String, now: Date) async throws {
    try await dao.updateWord(
      id: id, WordEdit(word: word, meaning: "りんご", ipa: "", partsOfSpeech: [], exampleEn: "", exampleTranslation: ""),
      now: now)
  }

  @Test("updateWord で単語名のキーが変わったら、元のキーを削除ログに残す")
  func renameLogsOldKey() async throws {
    let created = Date(timeIntervalSince1970: 1_700_000_000)
    let id = try await dao.insertWord(apple(" Aple "), now: created)

    try await rename(id, to: "apple", now: created.addingTimeInterval(60))

    #expect(try await dao.getDeletions() == [DeletedWord(word: "aple", deletedAt: created.addingTimeInterval(60))])
  }

  @Test("updateWord でキーが変わらない(大文字小文字・前後空白だけ)なら削除ログを残さない")
  func sameKeyEditLogsNothing() async throws {
    let id = try await dao.insertWord(apple("apple"))
    try await rename(id, to: " Apple ", now: .now)
    #expect(try await dao.getDeletions().isEmpty)
  }

  @Test(
    "元のキーの単語が他にも残っていれば、その単語を消さないよう削除ログを残さない(同期と同じキーで探す)",
    arguments: [("aple", "aple"), ("aple", " Aple "), ("éclair", "Éclair")])
  func renameKeepsDuplicateOfOldKey(renamed: String, remaining: String) async throws {
    let id = try await dao.insertWord(apple(renamed))
    try await dao.insertWord(apple(remaining))
    try await rename(id, to: "apple", now: .now)
    #expect(try await dao.getDeletions().isEmpty)
  }

  @Test("新しいキーの削除ログは、改名で取り消す")
  func renameClearsDeletionOfNewKey() async throws {
    let created = Date(timeIntervalSince1970: 1_700_000_000)
    let deleted = try await dao.insertWord(apple("apple"), now: created)
    try await dao.deleteWord(id: deleted, now: created)
    let id = try await dao.insertWord(apple("aple"), now: created)

    try await rename(id, to: "apple", now: created.addingTimeInterval(60))

    #expect(try await dao.getDeletions().map(\.word) == ["aple"])
  }

  @Test("deleteWord で行が消える")
  func deletesRow() async throws {
    let id = try await dao.insertWord(apple())

    try await dao.deleteWord(id: id)

    #expect(try await firstEmission().isEmpty)
  }

  // 重複登録の検出(DB に UNIQUE 制約は置かず、このクエリで抑止する)。
  @Test("findByWord は大文字小文字・前後空白を無視して既存の単語を返す")
  func findsIgnoringCaseAndSpaces() async throws {
    try await dao.insertWord(apple())

    #expect(try await dao.findByWord("apple")?.word == "apple")
    #expect(try await dao.findByWord("Apple")?.word == "apple")
    #expect(try await dao.findByWord("  APPLE  ")?.word == "apple")
  }

  @Test("findByWord は未登録の単語では nil を返す")
  func findReturnsNilForUnknown() async throws {
    try await dao.insertWord(apple())

    #expect(try await dao.findByWord("banana") == nil)
  }

  @Test("findByWord は excludingId で指定した 1 件を対象外にする(編集で自分自身に当たらない)")
  func findExcludesId() async throws {
    let id = try await dao.insertWord(apple())

    #expect(try await dao.findByWord("apple", excludingId: id) == nil)
    #expect(try await dao.findByWord("apple", excludingId: id + 1) != nil)
  }

  // 削除ログ(同期で削除を伝えるためのトゥームストーン)。
  @Test("deleteWord は削除ログを残す(キーは小文字化する)")
  func deleteLeavesTombstone() async throws {
    let id = try await dao.insertWord(apple("Apple"))

    try await dao.deleteWord(id: id)

    #expect(try await dao.getDeletions().map(\.word) == ["apple"])
  }

  @Test("存在しない id の deleteWord は削除ログを残さない")
  func deleteUnknownIdLeavesNoTombstone() async throws {
    try await dao.deleteWord(id: 999)

    #expect(try await dao.getDeletions().isEmpty)
  }

  @Test("削除した単語を再登録すると削除ログは取り消される")
  func reinsertClearsTombstone() async throws {
    let id = try await dao.insertWord(apple())
    try await dao.deleteWord(id: id)
    #expect(try await dao.getDeletions().count == 1)

    try await dao.insertWord(apple())

    #expect(try await dao.getDeletions().isEmpty)
  }

  @Test("pruneDeletions は指定日時より古いログだけ消す")
  func prunesOldTombstones() async throws {
    let oldId = try await dao.insertWord(apple("old", "古い"))
    try await dao.deleteWord(id: oldId, now: Date(timeIntervalSince1970: 1_577_836_800))  // 2020-01-01
    let recentId = try await dao.insertWord(apple("recent", "新しい"))
    try await dao.deleteWord(id: recentId)

    try await dao.pruneDeletions(before: Date(timeIntervalSince1970: 1_609_459_200))  // 2021-01-01

    #expect(try await dao.getDeletions().map(\.word) == ["recent"])
  }

  @Test("setLearned で isLearned を切り替えられる")
  func togglesLearned() async throws {
    let id = try await dao.insertWord(apple())

    try await dao.setLearned(id: id, true)
    #expect(try await dao.getAll().first?.isLearned == true)

    try await dao.setLearned(id: id, false)
    #expect(try await dao.getAll().first?.isLearned == false)
  }

  @Test("recordQuizResult(knew: true) は correctCount+1・lastReviewedAt を付け、updatedAt は変えない")
  func recordsKnewAnswer() async throws {
    let created = Date(timeIntervalSince1970: 1_700_000_000)
    let id = try await dao.insertWord(apple(), now: created)

    let answered = created.addingTimeInterval(60)
    try await dao.recordQuizResult(id: id, knew: true, now: answered)
    try await dao.recordQuizResult(id: id, knew: true, now: answered)

    let word = try #require(try await dao.getAll().first)
    #expect(word.correctCount == 2)
    #expect(word.lastReviewedAt == answered)
    // 回答の記録では updatedAt を進めない(内容の編集のために取っておく)。
    #expect(word.updatedAt == created)
  }

  @Test("recordQuizResult(knew: false) は correctCount 据え置きで lastReviewedAt を更新する")
  func recordsForgotAnswer() async throws {
    let id = try await dao.insertWord(apple())

    try await dao.recordQuizResult(id: id, knew: false)

    let word = try #require(try await dao.getAll().first)
    #expect(word.correctCount == 0)
    #expect(word.lastReviewedAt != nil)
  }

  @Test("getAll は observeAll と同じ並び順で全件返す")
  func getAllMatchesObserveOrder() async throws {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    try await dao.insertWord(apple("first", "一つ目"), now: now)
    try await dao.insertWord(apple("second", "二つ目"), now: now)

    #expect(try await dao.getAll().map(\.word) == ["second", "first"])
  }

  @Test("importWords は渡された createdAt/updatedAt をそのまま書き込む")
  func importKeepsTimestamps() async throws {
    let createdAt = Date(timeIntervalSince1970: 1_577_836_800)  // 2020-01-01
    let updatedAt = Date(timeIntervalSince1970: 1_577_923_200)  // 2020-01-02

    try await dao.importWords(
      inserts: [ImportedWord(word: "serendipity", meaning: "偶然の幸運", createdAt: createdAt, updatedAt: updatedAt)],
      updates: [])

    let word = try #require(try await dao.getAll().first)
    #expect(word.createdAt == createdAt)
    #expect(word.updatedAt == updatedAt)
  }

  @Test("importWords は insert と update を両方適用する")
  func importAppliesInsertsAndUpdates() async throws {
    let id = try await dao.insertWord(apple())
    let newUpdatedAt = Date(timeIntervalSince1970: 1_735_689_600)  // 2025-01-01
    let old = Date(timeIntervalSince1970: 1_577_836_800)

    try await dao.importWords(
      inserts: [ImportedWord(word: "banana", meaning: "バナナ", createdAt: old, updatedAt: old)],
      updates: [
        (id, .content(ImportedWord(word: "apple", meaning: "リンゴ", createdAt: old, updatedAt: newUpdatedAt)))
      ])

    let words = try await dao.getAll()
    #expect(words.count == 2)
    let apple = try #require(words.first { $0.word == "apple" })
    #expect(apple.meaning == "リンゴ")
    #expect(apple.updatedAt == newUpdatedAt)
    // 作成日時は DB 側を維持する。
    #expect(apple.createdAt != old)
    #expect(words.contains { $0.word == "banana" })
  }

  @Test("importWords は回答の実績だけの更新では内容も updatedAt も変えない")
  func importUpdatesOnlyQuizProgress() async throws {
    let created = Date(timeIntervalSince1970: 1_700_000_000)
    let id = try await dao.insertWord(apple(), now: created)
    let reviewed = created.addingTimeInterval(100)

    try await dao.importWords(
      inserts: [], updates: [(id, .quizProgress(lastReviewedAt: reviewed, correctCount: 3))])

    let word = try #require(try await dao.getAll().first)
    #expect(word.lastReviewedAt == reviewed)
    #expect(word.correctCount == 3)
    #expect(word.updatedAt == created)
    #expect(word.meaning == "りんご")
  }

  @Test("importWords はローカルの削除ログより古いログで巻き戻さない")
  func importKeepsNewerLocalTombstone() async throws {
    let newer = Date(timeIntervalSince1970: 1_700_000_100)
    let older = Date(timeIntervalSince1970: 1_700_000_000)
    try await dao.importWords(inserts: [], updates: [], deletions: [DeletedWord(word: "apple", deletedAt: newer)])

    try await dao.importWords(inserts: [], updates: [], deletions: [DeletedWord(word: "apple", deletedAt: older)])

    #expect(try await dao.getDeletions() == [DeletedWord(word: "apple", deletedAt: newer)])
  }
}
