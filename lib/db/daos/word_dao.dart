import 'package:drift/drift.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/db/tables.dart';

part 'word_dao.g.dart';

/// Words テーブルへのクエリを集約する(presentation 層から DB を直接触らない規約)。
/// createdAt / updatedAt の付与は呼び出し側でなく DAO が責任を持つ。
@DriftAccessor(tables: [Words, DeletedWords])
class WordDao extends DatabaseAccessor<AppDatabase> with _$WordDaoMixin {
  WordDao(super.db);

  /// 単語の同一判定キー(削除ログのマージ・重複登録の検出に使う)。
  /// WordExportService の突き合わせと揃える(大文字小文字・前後空白の違いで
  /// 別単語扱いにならないようにする)。
  String _matchKey(String word) => word.trim().toLowerCase();

  /// 同じ単語が既に登録されていれば返す(重複登録の検出用)。
  /// [excludeId] を渡すとその 1 件を除いて探す(編集で自分自身に当たらないため)。
  ///
  /// DB に UNIQUE 制約は置いていない(既存端末に重複が残っている可能性があり、
  /// 制約を足すとマイグレーションと iCloud インポートが失敗しうる)。
  /// 重複の抑止はこのクエリを使うアプリ層の検証だけで行う。
  Future<Word?> findByWord(String word, {int? excludeId}) {
    final query = select(words)
      ..where((t) => t.word.lower().equals(_matchKey(word)))
      ..limit(1);
    if (excludeId != null) {
      query.where((t) => t.id.equals(excludeId).not());
    }
    return query.getSingleOrNull();
  }

  /// 登録日時の新しい順(同時刻は id の新しい順)
  Stream<List<Word>> watchAll() => (select(words)
        ..orderBy([
          (t) => OrderingTerm.desc(t.createdAt),
          (t) => OrderingTerm.desc(t.id),
        ]))
      .watch();

  /// 登録日時の新しい順(watchAll と同じ並び)で全件取得する。
  /// JSON エクスポート用の同期版(watchAll の Stream 版とは別に用意)。
  Future<List<Word>> getAll() => (select(words)
        ..orderBy([
          (t) => OrderingTerm.desc(t.createdAt),
          (t) => OrderingTerm.desc(t.id),
        ]))
      .get();

  /// 登録されている単語の件数。
  /// 一覧を読まずに件数だけ知りたい呼び出し(レビュー依頼の判定)のために置く。
  Future<int> countWords() {
    final count = words.id.count();
    return (selectOnly(words)..addColumns([count])).map((row) {
      return row.read(count) ?? 0;
    }).getSingle();
  }

  /// 単語を追加する。同じ単語の削除ログが残っていれば取り消す
  /// (取り消さないと、削除 → 再登録した単語が次の同期でまた消えてしまう)。
  Future<int> insertWord(WordsCompanion entry) {
    final now = DateTime.now();
    return transaction(() async {
      final id = await into(words).insert(
        entry.copyWith(createdAt: Value(now), updatedAt: Value(now)),
      );
      if (entry.word.present) {
        await _clearDeletion(entry.word.value);
      }
      return id;
    });
  }

  Future<void> updateWord(int id, WordsCompanion entry) async {
    await (update(words)..where((t) => t.id.equals(id))).write(
      entry.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  /// 単語を削除し、同時に削除ログへ記録する(1 トランザクション)。
  /// ログが無いと、iCloud 同期で相手のスナップショットからこの単語が復活する。
  Future<void> deleteWord(int id) {
    return transaction(() async {
      final target = await (select(
        words,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (target == null) return;

      await (delete(words)..where((t) => t.id.equals(id))).go();
      await into(deletedWords).insertOnConflictUpdate(
        DeletedWordsCompanion(
          word: Value(_matchKey(target.word)),
          deletedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  /// 削除ログの全件(同期でクラウドへ送る用)。
  Future<List<DeletedWord>> getDeletions() => select(deletedWords).get();

  /// 指定単語の削除ログを取り消す(再登録・インポートでの復活時)。
  Future<void> _clearDeletion(String word) => (delete(
    deletedWords,
  )..where((t) => t.word.equals(_matchKey(word)))).go();

  /// [before] より古い削除ログを掃除する。
  /// ログを無期限に持ち続けるとスナップショットが膨らみ続けるため、
  /// 全端末が確実に同期し終える程度の期間だけ残す。
  Future<void> pruneDeletions(DateTime before) =>
      (delete(deletedWords)..where((t) => t.deletedAt.isSmallerThanValue(before)))
          .go();

  Future<void> setLearned(int id, {required bool isLearned}) =>
      (update(words)..where((t) => t.id.equals(id))).write(
        WordsCompanion(
          isLearned: Value(isLearned),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// クイズ回答を実績として記録する。lastReviewedAt = now、knew のとき correctCount を +1。
  /// updatedAt は「単語内容の編集」を表すものとして予約するため、実績記録では更新しない
  /// (将来の iCloud 同期でクイズ実績だけの端末が内容を上書きしないようにするため)。
  /// correctCount の加算は式更新で行い、読み取り→書き込みの競合を避ける。
  Future<void> recordQuizResult(int id, {required bool knew}) {
    final now = DateTime.now();
    return (update(words)..where((t) => t.id.equals(id))).write(
      knew
          ? WordsCompanion.custom(
              lastReviewedAt: Variable(now),
              correctCount: words.correctCount + const Constant(1),
            )
          : WordsCompanion(lastReviewedAt: Value(now)),
    );
  }

  /// JSON インポートの適用。insertWord / updateWord と異なり、
  /// createdAt / updatedAt を DAO 側で上書きせず、渡された Companion の値を
  /// そのまま書き込む(ファイル側のタイムスタンプを維持するため)。
  /// 全体を 1 トランザクションで実行し、途中失敗で中途半端な状態を残さない。
  ///
  /// [deleteIds] はファイル側の削除ログにより消す単語、[deletions] は取り込む
  /// 削除ログ本体(ローカルに該当単語が無くても、第 3 の端末へ伝播させるため
  /// ログだけは残す)。[inserts] された単語の削除ログは取り消す。
  Future<void> importWords({
    required List<WordsCompanion> inserts,
    required List<(int, WordsCompanion)> updates,
    List<int> deleteIds = const [],
    List<DeletedWordsCompanion> deletions = const [],
  }) {
    return transaction(() async {
      if (inserts.isNotEmpty) {
        await batch((b) => b.insertAll(words, inserts));
      }
      for (final (id, entry) in updates) {
        await (update(words)..where((t) => t.id.equals(id))).write(entry);
      }
      if (deleteIds.isNotEmpty) {
        await (delete(words)..where((t) => t.id.isIn(deleteIds))).go();
      }
      for (final entry in deletions) {
        // 既にローカルにある削除ログの方が新しければ残す
        // (古いスナップショットを取り込んでも記録が巻き戻らないように)。
        final existing = await (select(
          deletedWords,
        )..where((t) => t.word.equals(entry.word.value))).getSingleOrNull();
        if (existing != null &&
            !entry.deletedAt.value.isAfter(existing.deletedAt)) {
          continue;
        }
        await into(deletedWords).insertOnConflictUpdate(entry);
      }
      // 復活した単語の削除ログは取り消す。deletions を書いたあとに実行しないと、
      // 同じ単語が「追加」と「削除ログ」の両方に載っていた場合に消し漏れる。
      for (final entry in inserts) {
        if (entry.word.present) await _clearDeletion(entry.word.value);
      }
    });
  }
}
