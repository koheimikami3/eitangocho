import Foundation
import GRDB

/// 辞書(kaikki)のレスポンスキャッシュ dictionary_cache_entries へのクエリを集約する。
/// 成功したレスポンスだけを保存し、再取得しない方針。
///
/// 中身は生の JSONL ではなく、使う項目だけに絞って詰め直した JSON 配列
/// (Flutter 版の KaikkiApiClient と同じ形式。Swift 版も同じ形式で読み書きする)。
public struct DictionaryCacheDao: Sendable {
  let writer: any DatabaseWriter

  /// キャッシュ済みの JSON を返す。未キャッシュなら nil。
  public func find(_ word: String) async throws -> String? {
    try await writer.read { db in
      try String.fetchOne(
        db, sql: "SELECT response_json FROM dictionary_cache_entries WHERE word = ?", arguments: [word])
    }
  }

  public func save(_ word: String, responseJson: String, now: Date = .now) async throws {
    try await writer.write { db in
      try db.execute(
        sql: "INSERT OR REPLACE INTO dictionary_cache_entries (word, response_json, fetched_at) VALUES (?, ?, ?)",
        arguments: [word, responseJson, DatabaseTimestamp.seconds(now)])
    }
  }
}
