import EitangochoData
import Foundation
import Testing

@testable import EitangochoSync

/// Flutter 版の test/features/sync/data/sync_service_test.dart の移植。
struct SyncServiceTests {
  let database: AppDatabase
  let store = InMemoryCloudFileStore()
  let service: SyncService
  var dao: WordDao { database.wordDao }

  init() throws {
    database = try AppDatabase.inMemory()
    service = SyncService(store: store, database: database)
  }

  @discardableResult
  private func addWord(_ word: String, _ meaning: String) async throws -> Int64 {
    try await dao.insertWord(NewWord(word: word, meaning: meaning))
  }

  @Test("クラウドが空なら、ローカルの内容がそのまま書き出される")
  func writesLocalWhenCloudIsEmpty() async throws {
    try await addWord("apple", "りんご")

    let outcome = try await service.sync()

    #expect(!outcome.hasChanges)
    #expect(store.words == ["apple"])
  }

  @Test("クラウドにある単語がローカルへ取り込まれる")
  func importsCloudWords() async throws {
    // 1 台目が書いた状態を作る。
    try await addWord("apple", "りんご")
    try await service.sync()

    // 2 台目(空の DB)へ同じクラウドから取り込む。
    let database2 = try AppDatabase.inMemory()
    let store2 = InMemoryCloudFileStore()
    store2.contents = store.contents
    store2.modifiedAt = Date(timeIntervalSince1970: 1_767_225_600)

    let outcome = try await SyncService(store: store2, database: database2).sync()

    #expect(outcome.added == 1)
    #expect(try await database2.wordDao.getAll().map(\.word) == ["apple"])
  }

  @Test("両端末で同じ単語を編集したら updatedAt が新しい方が残る")
  func newerEditWins() async throws {
    let id = try await addWord("apple", "ローカルの訳")
    let local = try #require(try await dao.getAll().first)
    store.contents = snapshot(words: [("apple", "クラウドの訳", local.updatedAt.addingTimeInterval(86_400))])
    store.modifiedAt = .now

    let outcome = try await service.sync()

    #expect(outcome.updated == 1)
    let after = try #require(try await dao.getAll().first)
    #expect(after.id == id)
    #expect(after.meaning == "クラウドの訳")
  }

  @Test("クラウドの削除ログでローカルの単語が消え、復活しない")
  func cloudTombstoneDeletes() async throws {
    try await addWord("apple", "りんご")
    let local = try #require(try await dao.getAll().first)
    store.contents = snapshot(deletions: [("apple", local.updatedAt.addingTimeInterval(86_400))])
    store.modifiedAt = .now

    let outcome = try await service.sync()

    #expect(outcome.deleted == 1)
    #expect(try await dao.getAll().isEmpty)
    // 書き戻したスナップショットにも削除ログが残るので、次の同期でも復活しない。
    #expect(store.words.isEmpty)
    #expect(store.deletions == ["apple"])

    try await service.sync()
    #expect(try await dao.getAll().isEmpty)
  }

  @Test("ローカルの削除がクラウドへ伝わる")
  func localDeletionPropagates() async throws {
    let id = try await addWord("apple", "りんご")
    try await service.sync()
    #expect(store.words == ["apple"])

    try await dao.deleteWord(id: id)
    try await service.sync()

    #expect(store.words.isEmpty)
    #expect(store.deletions == ["apple"])
  }

  @Test("編集と同じ秒に削除しても復活しない")
  func sameSecondDeletionWins() async throws {
    // DB の日時は秒精度なので、編集の直後に削除すると updatedAt と deletedAt が
    // 同じ値になりうる。この引き分けで単語が復活しない(削除が勝つ)ことを固定する。
    let edited = Date(timeIntervalSince1970: 1_767_225_600)
    let id = try await dao.insertWord(NewWord(word: "apple", meaning: "りんご"), now: edited)
    try await service.sync()

    try await dao.deleteWord(id: id, now: edited)
    try await service.sync()

    #expect(try await dao.getAll().isEmpty)
    #expect(store.words.isEmpty)
  }

  @Test("読み取り後に他端末が書き込んだら、やり直してその内容を取り込む")
  func retriesWhenCloudChangesDuringSync() async throws {
    try await addWord("local", "ローカル")
    let store = store
    // 読み取りの直後に、別端末が 'remote' を含む内容を書いたことにする。
    store.onAfterRead = {
      store.contents = snapshot(words: [("remote", "リモート", nil)])
      store.modifiedAt = Date(timeIntervalSince1970: 1_780_000_000)
    }

    try await service.sync()

    // やり直しにより、他端末の 'remote' がローカルにもクラウドにも残る。
    #expect(Set(try await dao.getAll().map(\.word)).isSuperset(of: ["local", "remote"]))
    #expect(Set(store.words).isSuperset(of: ["local", "remote"]))
  }

  @Test("保持期間を過ぎた削除ログは書き出し前に掃除される")
  func prunesExpiredTombstones() async throws {
    let id = try await addWord("apple", "りんご")
    try await dao.deleteWord(id: id, now: Date.now.addingTimeInterval(-181 * 86_400))

    try await service.sync()

    #expect(store.deletions.isEmpty)
    #expect(try await dao.getDeletions().isEmpty)
  }

  @Test("最新のデータを取得できずに読み取りを見送ったら、書き戻さない")
  func doesNotWriteWhenNotCurrent() async throws {
    try await addWord("apple", "りんご")
    store.readError = .notCurrent

    await #expect(throws: CloudError.notCurrent) { try await service.sync() }

    #expect(store.writeCount == 0)
    #expect(store.contents == nil)
  }

  // MARK: - 競合版

  private func conflict(_ id: String, _ contents: String, modifiedAt: Date = .now) -> CloudConflict {
    CloudConflict(id: id, contents: contents, modifiedAt: modifiedAt)
  }

  @Test("競合版にだけある単語と、新しい編集が取り込まれる")
  func importsConflicts() async throws {
    try await addWord("apple", "ローカルの訳")
    let local = try #require(try await dao.getAll().first)
    store.conflicts = [
      conflict("a", snapshot(words: [("banana", "バナナ", nil)])),
      conflict("b", snapshot(words: [("apple", "競合版の訳", local.updatedAt.addingTimeInterval(86_400))])),
    ]

    let outcome = try await service.sync()

    #expect(outcome.added == 1)
    #expect(outcome.updated == 1)
    let words = Dictionary(uniqueKeysWithValues: try await dao.getAll().map { ($0.word, $0.meaning) })
    #expect(words == ["apple": "競合版の訳", "banana": "バナナ"])
    // 取り込んだ内容は書き戻したスナップショットにも載る。
    #expect(Set(store.words).isSuperset(of: ["apple", "banana"]))
  }

  @Test("競合版の古い編集では巻き戻らない")
  func olderConflictDoesNotRewind() async throws {
    try await addWord("apple", "ローカルの訳")
    let local = try #require(try await dao.getAll().first)
    store.conflicts = [
      conflict("a", snapshot(words: [("apple", "古い訳", local.updatedAt.addingTimeInterval(-86_400))]))
    ]

    try await service.sync()

    #expect(try await dao.getAll().first?.meaning == "ローカルの訳")
  }

  @Test("書き戻し後に、読み取った競合版だけが片付けられる")
  func resolvesOnlyReadConflicts() async throws {
    let store = store
    store.conflicts = [conflict("a", snapshot(words: [("banana", "バナナ", nil)]))]
    // 取り込みの後に、別の競合版が届いたことにする。
    store.onAfterReadConflicts = {
      store.conflicts.append(
        CloudConflict(id: "late", contents: snapshot(words: [("cherry", "さくらんぼ", nil)]), modifiedAt: .now))
    }

    try await service.sync()

    #expect(store.resolvedIds == ["a"])
    #expect(store.conflicts.map(\.id) == ["late"])
  }

  @Test("書き戻しに失敗したら競合版は片付けない")
  func keepsConflictsWhenWriteFails() async throws {
    store.conflicts = [conflict("a", snapshot(words: [("banana", "バナナ", nil)]))]
    store.writeError = .notCurrent

    await #expect(throws: CloudError.notCurrent) { try await service.sync() }

    #expect(store.resolvedIds.isEmpty)
    #expect(store.conflicts.count == 1)
  }

  @Test("削除ログの保持期間より古い競合版は、取り込まずに片付ける")
  func discardsExpiredConflicts() async throws {
    store.conflicts = [
      conflict("old", snapshot(words: [("banana", "バナナ", nil)]), modifiedAt: .now.addingTimeInterval(-181 * 86_400))
    ]

    let outcome = try await service.sync()

    #expect(outcome.added == 0)
    #expect(try await dao.getAll().isEmpty)
    #expect(store.resolvedIds == ["old"])
  }

  @Test("壊れた競合版は取り込まずに片付け、同期は続ける")
  func discardsBrokenConflicts() async throws {
    store.conflicts = [
      conflict("broken", "{not json"),
      conflict("ok", snapshot(words: [("banana", "バナナ", nil)])),
    ]

    try await service.sync()

    #expect(try await dao.getAll().map(\.word) == ["banana"])
    #expect(Set(store.resolvedIds) == ["broken", "ok"])
  }
}
