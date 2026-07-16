import 'package:drift/drift.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/db/tables.dart';

part 'word_dao.g.dart';

/// Words テーブルへのクエリを集約する(presentation 層から DB を直接触らない規約)。
/// createdAt / updatedAt の付与は呼び出し側でなく DAO が責任を持つ。
@DriftAccessor(tables: [Words])
class WordDao extends DatabaseAccessor<AppDatabase> with _$WordDaoMixin {
  WordDao(super.db);

  /// 登録日時の新しい順(同時刻は id の新しい順)
  Stream<List<Word>> watchAll() => (select(words)
        ..orderBy([
          (t) => OrderingTerm.desc(t.createdAt),
          (t) => OrderingTerm.desc(t.id),
        ]))
      .watch();

  Future<int> insertWord(WordsCompanion entry) {
    final now = DateTime.now();
    return into(words).insert(
      entry.copyWith(createdAt: Value(now), updatedAt: Value(now)),
    );
  }

  Future<void> updateWord(int id, WordsCompanion entry) async {
    await (update(words)..where((t) => t.id.equals(id))).write(
      entry.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> deleteWord(int id) =>
      (delete(words)..where((t) => t.id.equals(id))).go();

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
}
