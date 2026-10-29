import Foundation
import GRDB
import Testing

@testable import EitangochoData

/// Flutter 版の test/db/app_database_migration_test.dart の移植。
/// 古い Flutter 版から直接 Swift 版に更新した利用者の DB を開けることを確かめる。
struct AppDatabaseMigrationTests {
  private func words(_ database: AppDatabase) throws -> [Word] {
    try database.writer.read { db in try Word.fetchAll(db, sql: "SELECT * FROM words") }
  }

  private func cacheCount(_ database: AppDatabase) throws -> Int {
    try database.writer.read { db in
      try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM dictionary_cache_entries") ?? 0
    }
  }

  private func userVersion(_ database: AppDatabase) throws -> Int {
    try database.writer.read { db in try AppDatabase.userVersion(db) }
  }

  @Test("v1 の DB を開くと deleted_words が追加され、既存の単語は残る")
  func upgradesFromV1() throws {
    let queue = try DriftSchemaFixtures.queue { db in
      try DriftSchemaFixtures.createV1(db)
      try DriftSchemaFixtures.insertApple(db)
    }

    let database = try AppDatabase(queue)

    let word = try #require(try words(database).first)
    #expect(word.word == "apple")
    #expect(word.translationLanguage == "ja")
    #expect(try database.writer.read { try $0.tableExists("deleted_words") })
    #expect(try userVersion(database) == 7)
  }

  @Test("v2 の DB を開くと辞書キャッシュだけが空になり、単語は残る")
  func upgradesFromV2() throws {
    let queue = try DriftSchemaFixtures.queue { db in
      try DriftSchemaFixtures.createV2(db)
      try DriftSchemaFixtures.insertApple(db)
      try DriftSchemaFixtures.insertAppleCache(db)
    }

    let database = try AppDatabase(queue)

    #expect(try words(database).map(\.word) == ["apple"])
    #expect(try cacheCount(database) == 0)
    #expect(try userVersion(database) == 7)
  }

  @Test("v3 の DB を開くと訳の言語の列が ja で追加され、辞書キャッシュが空になる")
  func upgradesFromV3() throws {
    let queue = try DriftSchemaFixtures.queue { db in
      try DriftSchemaFixtures.createV2(db)
      try db.execute(sql: "PRAGMA user_version = 3")
      try DriftSchemaFixtures.insertApple(db)
      try DriftSchemaFixtures.insertAppleCache(db)
    }

    let database = try AppDatabase(queue)

    let word = try #require(try words(database).first)
    #expect(word.meaning == "りんご")
    #expect(word.translationLanguage == "ja")
    #expect(try cacheCount(database) == 0)
    #expect(try userVersion(database) == 7)
  }

  // v4 で列を足した後に v3 のアプリで開くと、列はそのまま user_version だけ
  // 3 に戻る(drift はダウングレードで何もせず版だけ書き戻す)。
  @Test("列が既にある v3 の DB も開け、辞書キャッシュが空になる")
  func upgradesFromV3WithColumn() throws {
    let queue = try DriftSchemaFixtures.queue { db in
      try DriftSchemaFixtures.createV4(db, userVersion: 3)
      try DriftSchemaFixtures.insertApple(db)
      try DriftSchemaFixtures.insertAppleCache(db)
    }

    let database = try AppDatabase(queue)

    #expect(try words(database).first?.translationLanguage == "ja")
    #expect(try cacheCount(database) == 0)
    #expect(try userVersion(database) == 7)
  }

  @Test("v4〜v6 の DB を開くと辞書キャッシュが空になり、単語と訳の言語は残る", arguments: [
    (4, "蘋果", "zh-Hant"),
    (5, "manzana", "es"),
    (6, "蘋果", "zh-Hant"),
  ])
  func upgradesFromV4ToV6(version: Int, meaning: String, language: String) throws {
    let queue = try DriftSchemaFixtures.queue { db in
      try DriftSchemaFixtures.createV4(db, userVersion: version)
      try DriftSchemaFixtures.insertApple(db, meaning: meaning, language: language)
      try DriftSchemaFixtures.insertAppleCache(db)
    }

    let database = try AppDatabase(queue)

    let word = try #require(try words(database).first)
    #expect(word.meaning == meaning)
    #expect(word.translationLanguage == language)
    #expect(try cacheCount(database) == 0)
    #expect(try userVersion(database) == 7)
  }

  @Test("v7 の DB は何も変えずに開く(辞書キャッシュも残る)")
  func opensV7AsIs() throws {
    let queue = try DriftSchemaFixtures.queue { db in
      try DriftSchemaFixtures.createV4(db, userVersion: 7)
      try DriftSchemaFixtures.insertApple(db)
      try DriftSchemaFixtures.insertAppleCache(db)
    }

    let database = try AppDatabase(queue)

    #expect(try words(database).count == 1)
    #expect(try cacheCount(database) == 1)
  }

  @Test("新規 DB は最新スキーマで作られ、GRDB の管理表は作らない")
  func createsFreshSchema() throws {
    let database = try AppDatabase.inMemory()

    let tables = try database.writer.read { db in
      try String.fetchAll(
        db, sql: "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name")
    }
    #expect(tables == ["deleted_words", "dictionary_cache_entries", "ejdict_entries", "words"])
    #expect(try userVersion(database) == 7)
  }

  @Test("新規 DB の列は drift の既定値で埋まる")
  func freshSchemaDefaults() throws {
    let database = try AppDatabase.inMemory()
    try database.writer.write { db in
      try db.execute(
        sql: "INSERT INTO words (word, japanese, created_at, updated_at) VALUES ('apple', 'りんご', 1, 2)")
    }

    let word = try #require(try words(database).first)
    #expect(word.ipa == "")
    #expect(word.partsOfSpeech == [])
    #expect(word.translationLanguage == "ja")
    #expect(word.isLearned == false)
    #expect(word.lastReviewedAt == nil)
    #expect(word.correctCount == 0)
    #expect(word.createdAt == Date(timeIntervalSince1970: 1))
    #expect(word.updatedAt == Date(timeIntervalSince1970: 2))
  }
}
