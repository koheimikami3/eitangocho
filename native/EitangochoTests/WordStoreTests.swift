import EitangochoData
import Foundation
import Testing

@testable import Eitangocho

@MainActor
struct WordStoreTests {
  private let database: AppDatabase
  private let store: WordStore

  init() throws {
    database = try AppDatabase.inMemory()
    store = WordStore(dao: database.wordDao, analytics: AnalyticsLogger(NoopAnalyticsClient()))
  }

  private func edit(_ meaning: String) -> WordEdit {
    WordEdit(word: "apple", meaning: meaning, ipa: "", partsOfSpeech: [], exampleEn: "", exampleTranslation: "")
  }

  @Test func 編集を保存できたらtrueを返す() async throws {
    try await database.wordDao.insertWord(NewWord(word: "apple", meaning: "りんご"))
    let word = try #require(try await database.wordDao.getAll().first)

    #expect(await store.update(word, edit("林檎")))
    #expect(try await database.wordDao.getAll().first?.meaning == "林檎")
  }

  @Test func 編集を書けなかったらfalseを返す() async throws {
    try await database.wordDao.insertWord(NewWord(word: "apple", meaning: "りんご"))
    let word = try #require(try await database.wordDao.getAll().first)
    // ディスクの不足などで UPDATE が失敗した状態を作る。
    try await database.writer.write { db in
      try db.execute(sql: "CREATE TRIGGER fail_update BEFORE UPDATE ON words BEGIN SELECT RAISE(ABORT, 'disk full'); END")
    }

    #expect(await store.update(word, edit("林檎")) == false)
    #expect(try await database.wordDao.getAll().first?.meaning == "りんご")
  }
}
