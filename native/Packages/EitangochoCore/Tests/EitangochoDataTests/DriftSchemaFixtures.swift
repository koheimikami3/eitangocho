import GRDB

/// Flutter 版の古い版が作った DB を再現する。
///
/// Flutter 版のテスト(test/db/app_database_migration_test.dart)と同じく、
/// 各版の DDL を直接書き起こす。
enum DriftSchemaFixtures {
  /// v1 相当のスキーマ(deleted_words が無い状態)。
  static func createV1(_ db: Database) throws {
    try db.execute(
      sql: """
        CREATE TABLE words (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          word TEXT NOT NULL,
          ipa TEXT NOT NULL DEFAULT '',
          japanese TEXT NOT NULL,
          parts_of_speech TEXT NOT NULL DEFAULT '',
          example_en TEXT NOT NULL DEFAULT '',
          example_ja TEXT NOT NULL DEFAULT '',
          audio_url TEXT NOT NULL DEFAULT '',
          is_learned INTEGER NOT NULL DEFAULT 0 CHECK ("is_learned" IN (0, 1)),
          last_reviewed_at INTEGER,
          correct_count INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        );
        CREATE TABLE ejdict_entries (
          word TEXT NOT NULL,
          meanings TEXT NOT NULL,
          PRIMARY KEY (word)
        );
        CREATE TABLE dictionary_cache_entries (
          word TEXT NOT NULL,
          response_json TEXT NOT NULL,
          fetched_at INTEGER NOT NULL,
          PRIMARY KEY (word)
        );
        PRAGMA user_version = 1;
        """)
  }

  /// v2 相当のスキーマ(v1 + deleted_words)。v3 はテーブル構造が同じ。
  static func createV2(_ db: Database) throws {
    try createV1(db)
    try db.execute(
      sql: """
        CREATE TABLE deleted_words (
          word TEXT NOT NULL,
          deleted_at INTEGER NOT NULL,
          PRIMARY KEY (word)
        );
        PRAGMA user_version = 2;
        """)
  }

  /// v4〜v7 相当のスキーマ(v2 + words.translation_language)。
  static func createV4(_ db: Database, userVersion: Int = 4) throws {
    try createV2(db)
    try db.execute(
      sql: """
        ALTER TABLE words ADD COLUMN translation_language TEXT NOT NULL DEFAULT 'ja';
        PRAGMA user_version = \(userVersion);
        """)
  }

  static func insertApple(_ db: Database, meaning: String = "りんご", language: String? = nil) throws {
    if let language {
      try db.execute(
        sql: """
          INSERT INTO words (word, japanese, translation_language, created_at, updated_at)
          VALUES ('apple', ?, ?, 0, 0)
          """,
        arguments: [meaning, language])
    } else {
      try db.execute(
        sql: "INSERT INTO words (word, japanese, created_at, updated_at) VALUES ('apple', ?, 0, 0)",
        arguments: [meaning])
    }
  }

  static func insertAppleCache(_ db: Database) throws {
    try db.execute(
      sql: """
        INSERT INTO dictionary_cache_entries (word, response_json, fetched_at)
        VALUES ('apple', '[{"word":"apple"}]', 0)
        """)
  }

  /// 古い版の DB を作った接続を返す。AppDatabase に渡すとスキーマが更新される。
  static func queue(_ build: (Database) throws -> Void) throws -> DatabaseQueue {
    let queue = try DatabaseQueue()
    try queue.writeWithoutTransaction { db in try build(db) }
    return queue
  }
}
