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
  /// v3: dictionary_cache_entries の中身を捨てる(辞書ソースの入れ替え)
  /// v4: words.translation_language を追加し、辞書キャッシュを捨てる(多言語化)
  /// v5: 辞書キャッシュを捨てる(訳の言語にスペイン語・フランス語を追加)
  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // v1 → v2 はテーブル追加のみ。既存 3 テーブルには一切触れない。
      if (from < 2) await m.createTable(deletedWords);
      // v2 → v3 は行の削除のみ(テーブル構造は変えない)。キャッシュには
      // Free Dictionary の生レスポンスが入っており、kaikki のパーサでは
      // 読めないため捨てる。次の自動入力で kaikki から入れ直される。
      if (from < 3) {
        await m.database.customStatement(
          'DELETE FROM dictionary_cache_entries',
        );
      }
      // v3 → v4 は列の追加と、辞書キャッシュの削除。キャッシュは訳語を
      // 日本語だけに絞って保存していたため、中国語の訳語を引けない。
      // 次の自動入力で kaikki から入れ直される(KaikkiApiClient._parseJsonl)。
      //
      // 列が既にあれば足さない。v4 で列を足した DB を v3 のアプリが開くと、
      // drift は列を残したまま user_version だけ 3 に書き戻すため、v4 で
      // 開き直すと ADD COLUMN が重複で失敗し、DB ごと開けなくなる(ストアでは
      // 戻せないが、開発機でリリース構成のビルドと旧ストア版が同居すると起きる)。
      if (from < 4) {
        final columns = await m.database
            .customSelect("SELECT name FROM pragma_table_info('words')")
            .get();
        final hasColumn = columns.any(
          (row) => row.read<String>('name') == words.translationLanguage.name,
        );
        if (!hasColumn) {
          await m.addColumn(words, words.translationLanguage);
        }
        await m.database.customStatement(
          'DELETE FROM dictionary_cache_entries',
        );
      }
      // v4 → v5 は辞書キャッシュの削除のみ。キャッシュは訳語を ja / cmn に
      // 絞って保存していたため、スペイン語・フランス語の訳語を引けない。
      // 訳の言語を足すたびに、ここで捨て直す必要がある。v3 からの更新では
      // 上で既に捨てているが、二度消しても害は無い。
      if (from < 5) {
        await m.database.customStatement(
          'DELETE FROM dictionary_cache_entries',
        );
      }
    },
  );
}
