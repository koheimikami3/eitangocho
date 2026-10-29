import GRDB

/// EJDict-hand(英和辞書)の ejdict_entries へのクエリを集約する。
public struct EjdictDao: Sendable {
  let writer: any DatabaseWriter

  /// 見出し語に一致するエントリの訳文字列を返す。未収録なら nil。
  public func lookup(_ word: String) async throws -> String? {
    try await writer.read { db in
      try String.fetchOne(db, sql: "SELECT meanings FROM ejdict_entries WHERE word = ?", arguments: [word])
    }
  }

  /// 初回の取り込み用。約 4.5 万行あるので、1 つのトランザクションで
  /// 同じ文を使い回して入れる。同じ見出し語は上書きする。
  public func bulkInsert(_ entries: [(word: String, meanings: String)]) async throws {
    try await writer.write { db in
      let statement = try db.makeStatement(
        sql: "INSERT OR REPLACE INTO ejdict_entries (word, meanings) VALUES (?, ?)")
      for entry in entries {
        try statement.execute(arguments: [entry.word, entry.meanings])
      }
    }
  }

  public func count() async throws -> Int {
    try await writer.read { db in try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM ejdict_entries") ?? 0 }
  }
}
