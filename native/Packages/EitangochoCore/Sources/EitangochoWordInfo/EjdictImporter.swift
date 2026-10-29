import EitangochoData
import Foundation
import OSLog

/// 同梱の EJDict-hand(英和辞書)の初回の取り込み。
///
/// 本文はアプリが `assets/ejdict/ejdict-hand-utf8.txt` をファイル参照で同梱し、その URL を渡す
/// (Flutter 版と同じファイル)。
public enum EjdictImporter {
  private static let logger = Logger(subsystem: "com.kohei.mikami.eitangocho", category: "ejdict")

  /// EJDict-hand のテキスト(1 行 =「単語 TAB 訳文字列」)をパースする。
  /// - タブで 2 分割できない行(空行等)はスキップ
  /// - 同一単語が複数行ある場合は訳を改行で連結して 1 レコードにする
  public static func parse(_ content: String) -> [(word: String, meanings: String)] {
    var order: [String] = []
    var merged: [String: String] = [:]
    for line in content.split(separator: "\n", omittingEmptySubsequences: false) {
      guard let tab = line.firstIndex(of: "\t"), tab != line.startIndex else { continue }
      let word = String(line[..<tab])
      let meanings = String(line[line.index(after: tab)...])
      guard !meanings.isEmpty else { continue }
      if let existing = merged[word] {
        merged[word] = existing + "\n" + meanings
      } else {
        order.append(word)
        merged[word] = meanings
      }
    }
    return order.map { ($0, merged[$0]!) }
  }

  /// 未取り込みなら取り込む。戻り値は取り込んだ件数(取り込み済みなら 0)。
  ///
  /// 取り込み済みかは設定のフラグでなく DB の件数で判定する
  /// (DB ファイル削除時に自動で復旧できるようにするため)。
  @discardableResult
  public static func importIfNeeded(dao: EjdictDao, source: URL) async throws -> Int {
    if try await dao.count() > 0 {
      logger.debug("EJDict: 取込済みのためスキップ")
      return 0
    }
    let entries = parse(try String(contentsOf: source, encoding: .utf8))
    try await dao.bulkInsert(entries)
    logger.info("EJDict: \(entries.count) 件を取り込んだ")
    return entries.count
  }
}
