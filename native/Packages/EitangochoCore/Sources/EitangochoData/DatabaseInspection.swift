import GRDB

/// DB の状態の要約(Dev ビルドの診断画面とログ用)。
public struct DatabaseInspection: Sendable, Equatable {
  public var userVersion: Int
  public var journalMode: String
  public var counts: DatabaseImportRecord.Counts
}

extension AppDatabase {
  public func inspect() async throws -> DatabaseInspection {
    try await writer.read { db in
      DatabaseInspection(
        userVersion: try Self.userVersion(db),
        journalMode: try String.fetchOne(db, sql: "PRAGMA journal_mode") ?? "-",
        counts: try Self.tableCounts(db))
    }
  }

  /// 4 テーブルの件数(引き継ぎの確認と診断画面で使う)。
  static func tableCounts(_ db: Database) throws -> DatabaseImportRecord.Counts {
    func count(_ table: String) throws -> Int {
      try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM \(table)") ?? 0
    }
    return .init(
      words: try count("words"), deletions: try count("deleted_words"),
      ejdict: try count("ejdict_entries"), dictionaryCache: try count("dictionary_cache_entries"))
  }
}
