import 'package:eitangocho/features/settings/data/word_export_service.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/sync/domain/cloud_file_store.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 1 回の同期で何が起きたか。UI の結果表示に使う。
class SyncOutcome {
  const SyncOutcome({
    required this.added,
    required this.updated,
    required this.deleted,
  });

  const SyncOutcome.none() : added = 0, updated = 0, deleted = 0;

  /// クラウドから取り込んで増えた単語
  final int added;

  /// クラウドの方が新しく上書きした単語
  final int updated;

  /// クラウドの削除ログにより消した単語
  final int deleted;

  bool get hasChanges => added > 0 || updated > 0 || deleted > 0;
}

/// iCloud 上の JSON スナップショット 1 個を介した双方向同期。
///
/// 「クラウドを読んでローカルへマージ → マージ後の全体を書き戻す」の 1 パスで
/// 双方向になる。競合解決は語単位の updatedAt 勝ちで、これは手動インポートと
/// 同じ [WordExportService] のマージロジックをそのまま使っている。
class SyncService {
  SyncService({
    required this.store,
    required this.exportService,
    required this.db,
  });

  final CloudFileStore store;
  final WordExportService exportService;
  final AppDatabase db;

  /// 削除ログを保持する期間。全端末が同期し終えるのに十分な長さを取りつつ、
  /// スナップショットが無限に膨らまないようにする。
  static const _deletionRetention = Duration(days: 180);

  /// 書き戻す直前に他端末の書き込みを検知したときのやり直し回数。
  static const _maxRetries = 1;

  /// 同期を 1 回実行する。
  ///
  /// 手順:
  ///   1. クラウドの更新日時を控える
  ///   2. クラウドの JSON を読み、ローカルへマージする
  ///   3. 競合版も読み、同じくマージする
  ///   4. マージ後のローカル全体を書き戻す
  ///   5. 書き戻す直前に 1 の更新日時が変わっていたら、他端末が書いたので
  ///      その内容を取りこぼさないよう最初からやり直す
  ///   6. 書き戻せたら、3 で取り込んだ競合版を片付ける
  Future<SyncOutcome> sync() async {
    for (var attempt = 0; ; attempt++) {
      final before = await store.lastModified();

      var added = 0;
      var updated = 0;
      var deleted = 0;
      // 同期ではこちらの削除ログを尊重する(まだ削除を知らないクラウドの
      // スナップショットから、消したはずの単語を復活させないため)。
      Future<void> merge(String json) async {
        final result = await exportService.importJson(
          json,
          respectLocalDeletions: true,
        );
        added += result.added;
        updated += result.updated;
        deleted += result.deleted;
      }

      final remote = await store.read();
      if (remote != null && remote.trim().isNotEmpty) await merge(remote);

      // 競合版には、古い内容での上書きで現行版から外れた他端末の変更が残っている。
      // 取り込みは updatedAt が新しいときだけ上書きするので、古い版を
      // 取り込んでも巻き戻らない。
      final conflicts = await store.readConflicts();
      final conflictCutoff = DateTime.now().subtract(_deletionRetention);
      for (final conflict in conflicts) {
        // 削除ログの保持期間より古い版は、掃除済みの削除を知らないまま
        // 単語を復活させうるので、取り込まずに片付けだけ行う。
        final modifiedAt = conflict.modifiedAt;
        if (modifiedAt != null && modifiedAt.isBefore(conflictCutoff)) continue;
        if (conflict.contents.trim().isEmpty) continue;
        try {
          await merge(conflict.contents);
        } on WordExportFormatException {
          // 壊れた版は取り込みようがない。残すと毎回失敗するので片付けだけ行う。
        }
      }

      // 古い削除ログを掃除してから書き出す(スナップショットに載せないため)。
      await db.wordDao.pruneDeletions(
        DateTime.now().subtract(_deletionRetention),
      );

      // 読み取りから書き込みまでの間に他端末が書いていないか確かめる。
      final now = await store.lastModified();
      if (attempt < _maxRetries && _changedSince(before, now)) continue;

      await store.write(await exportService.exportJson());
      // 片付けるのは、取り込んだ内容を書き戻せた後に限る。先に消すと、書き戻しに
      // 失敗したときにその変更がどこにも残らなくなる。
      if (conflicts.isNotEmpty) {
        await store.resolveConflicts([for (final c in conflicts) c.id]);
      }
      return SyncOutcome(added: added, updated: updated, deleted: deleted);
    }
  }

  /// クラウド側のファイルが読み取り時から変化したか。
  /// 未作成 → 作成済みへの変化も「変化した」とみなす。
  bool _changedSince(DateTime? before, DateTime? after) {
    if (before == null && after == null) return false;
    if (before == null || after == null) return true;
    return before != after;
  }
}

/// riverpod_generator は drift 生成型を扱う @riverpod を InvalidTypeException で
/// 落とす既知バグがあるため、この Provider は手書きにする
/// (lib/features/settings/data/word_export_service.dart と同じ方針)。
final syncServiceProvider = Provider<SyncService>(
  (ref) => SyncService(
    store: ref.watch(cloudFileStoreProvider),
    exportService: ref.watch(wordExportServiceProvider),
    db: ref.watch(databaseProvider),
  ),
);

/// クラウド保管先。テストではインメモリ実装に差し替える。
final cloudFileStoreProvider = Provider<CloudFileStore>(
  (ref) => throw UnimplementedError(
    'cloudFileStoreProvider は起動時に上書きすること(main.dart 参照)',
  ),
);
