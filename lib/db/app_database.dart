import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:eitangocho/db/converters/part_of_speech_list_converter.dart';
import 'package:eitangocho/db/daos/dictionary_cache_dao.dart';
import 'package:eitangocho/db/daos/ejdict_dao.dart';
import 'package:eitangocho/db/daos/word_dao.dart';
import 'package:eitangocho/db/tables.dart';
import 'package:eitangocho/enums/part_of_speech.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Words, DeletedWords, EjdictEntries, DictionaryCacheEntries],
  daos: [WordDao, EjdictDao, DictionaryCacheDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'eitangocho'));

  /// テスト用(NativeDatabase.memory() を渡す)
  AppDatabase.forTesting(super.executor);

  /// v1: words / ejdict_entries / dictionary_cache_entries
  /// v2: deleted_words を追加(iCloud 同期で削除を伝播させるため)
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // v1 → v2 はテーブル追加のみ。既存 3 テーブルには一切触れない。
      if (from < 2) await m.createTable(deletedWords);
    },
  );
}
