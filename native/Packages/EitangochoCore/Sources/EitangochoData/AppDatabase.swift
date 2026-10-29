import Foundation
import GRDB

/// 単語帳の SQLite。スキーマは Flutter 版(drift)の `AppDatabase` と同じ。
///
/// Flutter 版の DB ファイルを変換せずに開くため、スキーマの版は drift と同じく
/// `PRAGMA user_version` で持ち、drift の番号を引き継ぐ。GRDB の
/// `DatabaseMigrator` は使わない(`grdb_migrations` 表を作らない)。ファイルを
/// drift と互換のまま保てば、Flutter に戻す版が必要になってもそのまま開ける。
/// 今後スキーマを変えるときは v8 以降にし、列・テーブルの追加だけにする
/// (docs/design.md「データ・同期」)。
public final class AppDatabase: Sendable {
  /// drift の `schemaVersion` と同じ番号。
  public static let schemaVersion = 7

  public let writer: any DatabaseWriter

  /// 開いた接続に、必要ならスキーマの作成・更新をかけて使える状態にする。
  public init(_ writer: any DatabaseWriter) throws {
    self.writer = writer
    try writer.write { db in try Self.prepare(db) }
  }

  /// ファイルの DB を開く。
  ///
  /// WAL の `DatabasePool` で開く。DB は App Group に置いて将来のウィジェットと
  /// 共有するため、iOS では中断時にファイルロックを手放す設定も入れる
  /// (App Group の中でロックを持ったまま中断されると、OS に 0xdead10cc で落とされる)。
  public static func open(at url: URL) throws -> AppDatabase {
    var configuration = Configuration()
    configuration.observesSuspensionNotifications = true
    return try AppDatabase(DatabasePool(path: url.path, configuration: configuration))
  }

  /// テスト用のメモリ上の DB。
  public static func inMemory() throws -> AppDatabase {
    try AppDatabase(DatabaseQueue())
  }

  public var wordDao: WordDao { WordDao(writer: writer) }
  public var ejdictDao: EjdictDao { EjdictDao(writer: writer) }
  public var dictionaryCacheDao: DictionaryCacheDao { DictionaryCacheDao(writer: writer) }

  // MARK: - スキーマ

  /// 空の DB ならスキーマを作り、古い版なら drift と同じ手順で最新まで上げる。
  ///
  /// 新しい版(> schemaVersion)はそのまま使う。drift もダウングレードでは
  /// 何もしないので、挙動を揃えておく。
  static func prepare(_ db: Database) throws {
    let version = try userVersion(db)
    if version == 0, try !db.tableExists("words") {
      try createSchema(db)
    } else if version < schemaVersion {
      try upgrade(db, from: version)
    } else {
      return
    }
    try db.execute(sql: "PRAGMA user_version = \(schemaVersion)")
  }

  static func userVersion(_ db: Database) throws -> Int {
    try Int.fetchOne(db, sql: "PRAGMA user_version") ?? 0
  }

  /// 新規インストールの DB。DDL は drift が生成するものと同じにする。
  private static func createSchema(_ db: Database) throws {
    try db.execute(
      sql: """
        CREATE TABLE "words" (
          "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          "word" TEXT NOT NULL,
          "ipa" TEXT NOT NULL DEFAULT '',
          "japanese" TEXT NOT NULL,
          "parts_of_speech" TEXT NOT NULL DEFAULT '',
          "example_en" TEXT NOT NULL DEFAULT '',
          "example_ja" TEXT NOT NULL DEFAULT '',
          "translation_language" TEXT NOT NULL DEFAULT 'ja',
          "audio_url" TEXT NOT NULL DEFAULT '',
          "is_learned" INTEGER NOT NULL DEFAULT 0 CHECK ("is_learned" IN (0, 1)),
          "last_reviewed_at" INTEGER NULL,
          "correct_count" INTEGER NOT NULL DEFAULT 0,
          "created_at" INTEGER NOT NULL,
          "updated_at" INTEGER NOT NULL
        );
        CREATE TABLE "deleted_words" (
          "word" TEXT NOT NULL,
          "deleted_at" INTEGER NOT NULL,
          PRIMARY KEY ("word")
        );
        CREATE TABLE "ejdict_entries" (
          "word" TEXT NOT NULL,
          "meanings" TEXT NOT NULL,
          PRIMARY KEY ("word")
        );
        CREATE TABLE "dictionary_cache_entries" (
          "word" TEXT NOT NULL,
          "response_json" TEXT NOT NULL,
          "fetched_at" INTEGER NOT NULL,
          PRIMARY KEY ("word")
        );
        """)
  }

  /// Flutter 版の `AppDatabase.migration`(onUpgrade)の移植。
  ///
  /// 古い Flutter 版から直接 Swift 版に更新する利用者がいるため、v1 からの
  /// どの版でも開けるようにしておく。各段は二度かけても壊れない形にしてある。
  private static func upgrade(_ db: Database, from version: Int) throws {
    // v1 → v2: 同期で削除を伝えるための deleted_words を足す。
    if version < 2, try !db.tableExists("deleted_words") {
      try db.execute(
        sql: """
          CREATE TABLE "deleted_words" (
            "word" TEXT NOT NULL,
            "deleted_at" INTEGER NOT NULL,
            PRIMARY KEY ("word")
          )
          """)
    }
    // v3 → v4: 訳の言語の列を足す。
    //
    // 列が既にあれば足さない。v4 で列を足した DB を v3 のアプリが開くと、
    // drift は列を残したまま user_version だけ 3 に書き戻すため、ADD COLUMN が
    // 重複で失敗して DB ごと開けなくなる。
    if version < 4, try !db.columns(in: "words").contains(where: { $0.name == "translation_language" }) {
      try db.execute(
        sql: #"ALTER TABLE "words" ADD COLUMN "translation_language" TEXT NOT NULL DEFAULT 'ja'"#)
    }
    // v2 → v3 以降の各段(v3〜v7)は、どれも辞書キャッシュを捨てるだけ。
    // キャッシュの形式や残す訳語を変えるたびに捨て直しており、次の自動入力で
    // kaikki から入れ直される。
    if version < 7 {
      try db.execute(sql: "DELETE FROM dictionary_cache_entries")
    }
  }
}
