import 'package:drift/drift.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/db/tables.dart';

part 'dictionary_cache_dao.g.dart';

/// DictionaryCacheEntries テーブルへのクエリを集約する
/// (presentation 層から DB を直接触らない規約)。
/// kaikki のレスポンスは成功時のみ保存し、再フェッチしない方針。
@DriftAccessor(tables: [DictionaryCacheEntries])
class DictionaryCacheDao extends DatabaseAccessor<AppDatabase>
    with _$DictionaryCacheDaoMixin {
  DictionaryCacheDao(super.db);

  /// キャッシュ済みの生レスポンス JSON を返す。未キャッシュなら null。
  Future<String?> find(String word) async {
    final entry = await (select(dictionaryCacheEntries)
          ..where((t) => t.word.equals(word)))
        .getSingleOrNull();
    return entry?.responseJson;
  }

  Future<void> save(String word, String responseJson) =>
      into(dictionaryCacheEntries).insert(
        DictionaryCacheEntriesCompanion.insert(
          word: word,
          responseJson: responseJson,
          fetchedAt: DateTime.now(),
        ),
        mode: InsertMode.insertOrReplace,
      );
}
