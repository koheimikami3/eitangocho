import 'package:drift/drift.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/db/tables.dart';

part 'ejdict_dao.g.dart';

/// EjdictEntries テーブルへのクエリを集約する(presentation 層から DB を直接触らない規約)。
@DriftAccessor(tables: [EjdictEntries])
class EjdictDao extends DatabaseAccessor<AppDatabase> with _$EjdictDaoMixin {
  EjdictDao(super.db);

  /// 見出し語に一致するエントリの訳文字列を返す。未収録なら null。
  Future<String?> lookup(String word) async {
    final entry = await (select(ejdictEntries)
          ..where((t) => t.word.equals(word)))
        .getSingleOrNull();
    return entry?.meanings;
  }

  /// 初回取込用のバッチ INSERT。約 4.5 万行を 1 レコードずつ insert すると遅いため、
  /// チャンクごとの batch を 1 トランザクションにまとめて実行する。
  Future<void> bulkInsert(List<EjdictEntriesCompanion> entries) {
    const chunkSize = 5000;
    return transaction(() async {
      for (var i = 0; i < entries.length; i += chunkSize) {
        final chunk = entries.sublist(
          i,
          i + chunkSize > entries.length ? entries.length : i + chunkSize,
        );
        await batch(
          (b) => b.insertAll(
            ejdictEntries,
            chunk,
            mode: InsertMode.insertOrReplace,
          ),
        );
      }
    });
  }

  Future<int> count() async {
    final countExp = ejdictEntries.word.count();
    final query = selectOnly(ejdictEntries)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp)!;
  }
}
