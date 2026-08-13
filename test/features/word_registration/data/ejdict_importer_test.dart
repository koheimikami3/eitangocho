import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word_registration/data/ejdict_importer.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseEjdict', () {
    test('タブ区切りの行をパースする', () {
      final entries = parseEjdict('apple\tリンゴ\nbook\t本 / 書物');

      expect(entries, hasLength(2));
      expect(entries[0].word.value, 'apple');
      expect(entries[0].meanings.value, 'リンゴ');
      expect(entries[1].word.value, 'book');
      expect(entries[1].meanings.value, '本 / 書物');
    });

    test('タブで 2 分割できない行はスキップする', () {
      final entries = parseEjdict('apple\tリンゴ\n\nタブなし行\n\tタブ先頭\nempty\t\n');

      expect(entries, hasLength(1));
      expect(entries[0].word.value, 'apple');
    });

    test('同一単語の複数行は訳を改行で連結して 1 レコードにする', () {
      final entries = parseEjdict('coup\t不意の一撃\nbook\t本\ncoup\t=coup d\'état');

      expect(entries, hasLength(2));
      final coup = entries.singleWhere((e) => e.word.value == 'coup');
      expect(coup.meanings.value, '不意の一撃\n=coup d\'état');
    });
  });

  group('ejdictImportProvider', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('取込済み(count > 0)なら asset を読まず 0 を返す', () async {
      await db.ejdictDao.bulkInsert(parseEjdict('apple\tリンゴ'));

      // 未取込だと rootBundle.loadString で asset 読込に進むため、
      // 0 が返る = count 判定でスキップされたことを意味する。
      final imported = await container.read(ejdictImportProvider.future);

      expect(imported, 0);
      expect(await db.ejdictDao.count(), 1);
    });
  });
}
