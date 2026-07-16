import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:eitangocho/db/converters/part_of_speech_list_converter.dart';
import 'package:eitangocho/db/daos/ejdict_dao.dart';
import 'package:eitangocho/db/daos/word_dao.dart';
import 'package:eitangocho/db/tables.dart';
import 'package:eitangocho/enums/part_of_speech.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Words, EjdictEntries, DictionaryCacheEntries],
  daos: [WordDao, EjdictDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'eitangocho'));

  /// テスト用(NativeDatabase.memory() を渡す)
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
