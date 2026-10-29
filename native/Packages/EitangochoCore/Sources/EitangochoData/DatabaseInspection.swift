import GRDB

/// DB の状態の要約(Dev ビルドの診断画面とログ用)。
public struct DatabaseInspection: Sendable, Equatable {
  public var userVersion: Int
  public var journalMode: String
  public var words: Int
  public var deletions: Int
  public var ejdict: Int
  public var dictionaryCache: Int
}

extension AppDatabase {
  public func inspect() async throws -> DatabaseInspection {
    try await writer.read { db in
      func count(_ table: String) throws -> Int {
        try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM \(table)") ?? 0
      }
      return DatabaseInspection(
        userVersion: try Self.userVersion(db),
        journalMode: try String.fetchOne(db, sql: "PRAGMA journal_mode") ?? "-",
        words: try count("words"),
        deletions: try count("deleted_words"),
        ejdict: try count("ejdict_entries"),
        dictionaryCache: try count("dictionary_cache_entries"))
    }
  }
}
