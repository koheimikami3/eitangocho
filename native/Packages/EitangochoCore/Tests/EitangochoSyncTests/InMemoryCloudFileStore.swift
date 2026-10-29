import Foundation

@testable import EitangochoSync

/// テスト用のメモリ上の保管先。1 つの「クラウド」を複数の端末が共有する
/// 状況を作れるよう、内容と更新日時だけを持つ。テストは逐次に動かすので排他はしない。
final class InMemoryCloudFileStore: CloudFileStore, @unchecked Sendable {
  var contents: String?
  var modifiedAt: Date?

  /// read の直後に差し込む処理。読み取りと書き戻しの間に他端末が割り込む
  /// 状況を作るのに使う(1 度だけ発火する)。
  var onAfterRead: (() -> Void)?

  var readCount = 0
  var writeCount = 0

  /// 未解決の競合版。resolveConflicts で消えた id は `resolvedIds` に残る。
  var conflicts: [CloudConflict] = []
  var resolvedIds: [String] = []

  /// readConflicts の直後に差し込む処理(1 度だけ発火する)。
  var onAfterReadConflicts: (() -> Void)?

  /// read / write で投げる失敗(最新化を待ちきれず見送った場合などの再現用)。
  var readError: CloudError?
  var writeError: CloudError?

  func read() async throws -> String? {
    readCount += 1
    if let readError { throw readError }
    let value = contents
    let hook = onAfterRead
    onAfterRead = nil
    hook?()
    return value
  }

  func lastModified() async throws -> Date? { modifiedAt }

  func readConflicts() async throws -> [CloudConflict] {
    let value = conflicts
    let hook = onAfterReadConflicts
    onAfterReadConflicts = nil
    hook?()
    return value
  }

  func resolveConflicts(_ ids: [String]) async throws {
    conflicts.removeAll { ids.contains($0.id) }
    resolvedIds += ids
  }

  func write(_ value: String) async throws {
    if let writeError { throw writeError }
    contents = value
    // 実際のファイルシステムと同じく、書くたびに更新日時が進む。
    modifiedAt = (modifiedAt ?? Date(timeIntervalSince1970: 1_767_225_600)).addingTimeInterval(1)
    writeCount += 1
  }

  /// クラウド上の JSON に含まれる単語。
  var words: [String] { entries("words") }
  /// クラウド上の JSON に含まれる削除ログ。
  var deletions: [String] { entries("deletions") }

  private func entries(_ key: String) -> [String] {
    guard let contents,
      let object = try? JSONSerialization.jsonObject(with: Data(contents.utf8)) as? [String: Any],
      let list = object[key] as? [[String: Any]]
    else { return [] }
    return list.compactMap { $0["word"] as? String }
  }
}

/// 単語 1 つだけを持つ同期ファイルの JSON。
func snapshot(
  words: [(word: String, meaning: String, updatedAt: Date?)] = [],
  deletions: [(word: String, deletedAt: Date)] = []
) -> String {
  let object: [String: Any] = [
    "version": 2,
    "exportedAt": ExportDate.format(.now),
    "words": words.map { entry -> [String: Any] in
      var json: [String: Any] = ["word": entry.word, "japanese": entry.meaning]
      if let updatedAt = entry.updatedAt { json["updatedAt"] = ExportDate.format(updatedAt) }
      return json
    },
    "deletions": deletions.map { ["word": $0.word, "deletedAt": ExportDate.format($0.deletedAt)] },
  ]
  return String(decoding: try! JSONSerialization.data(withJSONObject: object), as: UTF8.self)
}
