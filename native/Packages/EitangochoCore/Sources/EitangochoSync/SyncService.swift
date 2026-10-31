import EitangochoData
import Foundation

/// 1 回の同期で何が起きたか。画面の結果表示に使う。
public struct SyncOutcome: Sendable, Equatable {
  /// クラウドから取り込んで増えた単語。
  public var added = 0
  /// クラウドの方が新しく上書きした単語。
  public var updated = 0
  /// クラウドの削除ログにより消した単語。
  public var deleted = 0

  public var hasChanges: Bool { added > 0 || updated > 0 || deleted > 0 }
}

/// iCloud 上の JSON スナップショット 1 個を介した双方向同期(Flutter 版の SyncService の移植)。
///
/// 「クラウドを読んでローカルへマージ → マージ後の全体を書き戻す」の 1 パスで
/// 双方向になる。競合の解決は単語ごとの updatedAt 勝ちで、手動の取り込みと
/// 同じ WordExportService のマージをそのまま使う。
public struct SyncService: Sendable {
  /// 削除ログを残す期間。全端末が同期し終えるのに十分な長さを取りつつ、
  /// スナップショットが無限に膨らまないようにする。
  static let deletionRetention: TimeInterval = 180 * 86_400

  /// 書き戻す直前に他端末の書き込みを見つけたときのやり直しの回数。
  static let maxRetries = 1

  let store: any CloudFileStore
  let exportService: WordExportService
  let database: AppDatabase

  public init(store: any CloudFileStore, database: AppDatabase) {
    self.store = store
    self.exportService = WordExportService(database: database)
    self.database = database
  }

  /// 同期を 1 回行う。
  ///
  /// 手順:
  ///   1. クラウドの更新日時を控える
  ///   2. クラウドの JSON を読み、ローカルへマージする
  ///   3. 競合版も読み、同じくマージする
  ///   4. マージ後のローカル全体を書き戻す
  ///   5. 書き戻す直前に 1 の更新日時が変わっていたら、他端末が書いたので
  ///      その内容を取りこぼさないよう最初からやり直す
  ///   6. 書き戻せたら、3 で取り込んだ競合版を片付ける
  @discardableResult
  public func sync(now: @Sendable () -> Date = { .now }) async throws -> SyncOutcome {
    var attempt = 0
    while true {
      defer { attempt += 1 }
      let before = try await store.lastModified()
      var outcome = SyncOutcome()

      // 同期ではこちらの削除ログを尊重する(まだ削除を知らないクラウドの
      // スナップショットから、消したはずの単語を復活させないため)。
      func merge(_ json: String) async throws {
        let result = try await exportService.importJson(json, respectLocalDeletions: true, now: now())
        outcome.added += result.added
        outcome.updated += result.updated
        outcome.deleted += result.deleted
      }

      if let remote = try await store.read(), !remote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        try await merge(remote)
      }

      // 競合版には、古い内容での上書きで現行版から外れた他端末の変更が残っている。
      // 取り込みは updatedAt が新しいときだけ上書きするので、古い版を取り込んでも巻き戻らない。
      let conflicts = try await store.readConflicts()
      let cutoff = now().addingTimeInterval(-Self.deletionRetention)
      for conflict in conflicts {
        // 削除ログの保持期間より古い版は、掃除済みの削除を知らないまま単語を
        // 復活させうるので、取り込まずに片付けだけ行う。
        if let modifiedAt = conflict.modifiedAt, modifiedAt < cutoff { continue }
        if conflict.contents.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { continue }
        do {
          try await merge(conflict.contents)
        } catch is WordExportFormatError {
          // 壊れた版は取り込みようがない。残すと毎回失敗するので片付けだけ行う。
        }
      }

      // 古い削除ログを掃除してから書き出す(スナップショットに載せないため)。
      try await database.wordDao.pruneDeletions(before: cutoff)

      // 読み取りから書き込みまでの間に他端末が書いていないか確かめる。
      // 未作成 → 作成済みへの変化も「変わった」とみなす。
      let current = try await store.lastModified()
      if attempt < Self.maxRetries, before != current { continue }

      try await store.write(try await exportService.exportJson(now: now()))
      // 片付けるのは、取り込んだ内容を書き戻せた後に限る。先に消すと、書き戻しに
      // 失敗したときにその変更がどこにも残らなくなる。
      if !conflicts.isEmpty {
        try await store.resolveConflicts(conflicts.map(\.id))
      }
      return outcome
    }
  }
}
