import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/settings/data/word_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late WordExportService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = WordExportService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('エクスポートした JSON をインポートすると内容が一致する(roundtrip)', () async {
    await db.wordDao.insertWord(
      const WordsCompanion(
        word: Value('serendipity'),
        meaning: Value('偶然の幸運'),
        ipa: Value('/ˌserənˈdɪpəti/'),
        partsOfSpeech: Value([PartOfSpeech.noun]),
        exampleEn: Value('Meeting her was pure serendipity.'),
        exampleTranslation: Value('彼女に出会えたのはまったくの偶然の幸運だった。'),
      ),
    );

    final json = await service.exportJson();
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    expect(decoded['version'], 2);
    expect(decoded['exportedAt'], isNotNull);
    final words = decoded['words'] as List;
    expect(words, hasLength(1));
    expect((words.single as Map<String, dynamic>).containsKey('id'), isFalse);

    await db.wordDao.deleteWord((await db.wordDao.getAll()).single.id);
    expect(await db.wordDao.getAll(), isEmpty);

    final result = await service.importJson(json);
    expect(result.added, 1);
    expect(result.updated, 0);
    expect(result.unchanged, 0);
    expect(result.skipped, 0);

    final imported = (await db.wordDao.getAll()).single;
    expect(imported.word, 'serendipity');
    expect(imported.meaning, '偶然の幸運');
    expect(imported.ipa, '/ˌserənˈdɪpəti/');
    expect(imported.partsOfSpeech, [PartOfSpeech.noun]);
    expect(imported.exampleEn, 'Meeting her was pure serendipity.');
  });

  test('ファイル側 updatedAt が新しければ上書きされる', () async {
    final id = await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), meaning: Value('りんご')),
    );
    final existing = (await db.wordDao.getAll()).single;
    final newerUpdatedAt = existing.updatedAt.add(const Duration(days: 1));

    final json = _buildExportJson([
      _entryJson(word: 'apple', meaning: 'リンゴ', updatedAt: newerUpdatedAt),
    ]);

    final result = await service.importJson(json);
    expect(result.added, 0);
    expect(result.updated, 1);
    expect(result.unchanged, 0);

    final after = await db.wordDao.getAll();
    expect(after, hasLength(1));
    expect(after.single.id, id);
    expect(after.single.meaning, 'リンゴ');
    // word 表記と createdAt は DB 側を維持する。
    expect(after.single.word, 'apple');
  });

  test('ファイル側 updatedAt が古い・同時刻なら上書きされない(変更なし)', () async {
    final id = await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), meaning: Value('りんご')),
    );
    final existing = (await db.wordDao.getAll()).single;
    final olderUpdatedAt = existing.updatedAt.subtract(const Duration(days: 1));

    final json = _buildExportJson([
      _entryJson(word: 'apple', meaning: 'リンゴ', updatedAt: olderUpdatedAt),
    ]);

    final result = await service.importJson(json);
    expect(result.updated, 0);
    expect(result.unchanged, 1);

    final after = await db.wordDao.getAll();
    expect(after.single.id, id);
    expect(after.single.meaning, 'りんご');
  });

  test('単語の照合は trim + 小文字化で行い、DB 側の表記を維持する', () async {
    await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), meaning: Value('りんご')),
    );
    final existing = (await db.wordDao.getAll()).single;
    final newerUpdatedAt = existing.updatedAt.add(const Duration(days: 1));

    final json = _buildExportJson([
      _entryJson(word: ' Apple ', meaning: 'リンゴ', updatedAt: newerUpdatedAt),
    ]);

    final result = await service.importJson(json);
    expect(result.updated, 1);

    final after = await db.wordDao.getAll();
    expect(after, hasLength(1));
    expect(after.single.word, 'apple');
    expect(after.single.meaning, 'リンゴ');
  });

  test('word・meaning の欠落や型不正・空文字はスキップして続行する', () async {
    final json = jsonEncode({
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'words': [
        {'japanese': '訳のみ'}, // word 欠落
        {'word': 'no-japanese'}, // meaning 欠落
        {'word': 123, 'japanese': '型不正'}, // word が数値
        {'word': '  ', 'japanese': '空白のみ'}, // trim 後空文字
        {'word': 'valid', 'japanese': '有効'},
      ],
    });

    final result = await service.importJson(json);
    expect(result.skipped, 4);
    expect(result.added, 1);

    final words = await db.wordDao.getAll();
    expect(words.single.word, 'valid');
  });

  test('未知の version は例外を投げて中断する', () async {
    final json = jsonEncode({
      'version': 99,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'words': <dynamic>[],
    });

    await expectLater(
      () => service.importJson(json),
      throwsA(isA<WordExportFormatException>()),
    );
  });

  test('壊れた JSON は例外を投げる', () async {
    await expectLater(
      () => service.importJson('{not valid json'),
      throwsA(isA<WordExportFormatException>()),
    );
  });

  // 多言語化。v2.5.0 より前の版が書いたファイルには translationLanguage が無い。
  test('translationLanguage の無い行は日本語として取り込み、ある行はそのまま持ち回す', () async {
    final json = jsonEncode({
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'words': [
        {'word': 'apple', 'japanese': 'りんご'},
        {'word': 'achieve', 'japanese': '實現', 'translationLanguage': 'zh-Hant'},
      ],
    });

    await service.importJson(json);

    final byWord = {
      for (final w in await db.wordDao.getAll()) w.word: w.translationLanguage,
    };
    expect(byWord, {'apple': 'ja', 'achieve': 'zh-Hant'});

    // 書き出しにも載り、JSON のキーは訳の言語によらず japanese のまま。
    final exported = jsonDecode(await service.exportJson()) as Map;
    final achieve = (exported['words'] as List).cast<Map>().firstWhere(
      (w) => w['word'] == 'achieve',
    );
    expect(achieve['japanese'], '實現');
    expect(achieve['translationLanguage'], 'zh-Hant');
  });

  test('未知の partsOfSpeech 名は捨てて既知の値だけ復元する', () async {
    final json = jsonEncode({
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'words': [
        {
          'word': 'apple',
          'japanese': 'りんご',
          'partsOfSpeech': ['noun', 'unknownPos'],
        },
      ],
    });

    final result = await service.importJson(json);
    expect(result.added, 1);

    final words = await db.wordDao.getAll();
    expect(words.single.partsOfSpeech, [PartOfSpeech.noun]);
  });

  test('ファイル内に同一単語が複数あれば updatedAt が新しい方だけ採用する', () async {
    final older = DateTime.utc(2020, 1, 1);
    final newer = DateTime.utc(2021, 1, 1);
    final json = _buildExportJson([
      _entryJson(word: 'apple', meaning: '古い訳', updatedAt: older),
      _entryJson(word: 'apple', meaning: '新しい訳', updatedAt: newer),
    ]);

    final result = await service.importJson(json);
    expect(result.added, 1);
    expect(result.unchanged, 1);

    final words = await db.wordDao.getAll();
    expect(words, hasLength(1));
    expect(words.single.meaning, '新しい訳');
  });

  // 削除ログ(version 2)。既存の他テストは version 1 のファイルを使っており、
  // 後方互換(v1 を deletions 無しとして取り込めること)もそこで担保している。
  group('lastReviewedAt', () {
    // drift の DateTime は秒精度で保存されるため、比較に使う日時は秒単位にする。
    final older = DateTime(2026, 9, 1, 10);
    final newer = DateTime(2026, 9, 2, 10);

    /// apple を登録し、lastReviewedAt を [reviewedAt] にした既存行を返す。
    Future<Word> seedApple(DateTime? reviewedAt) async {
      final id = await db.wordDao.insertWord(
        const WordsCompanion(word: Value('apple'), meaning: Value('りんご')),
      );
      await (db.update(db.words)..where((t) => t.id.equals(id))).write(
        WordsCompanion(lastReviewedAt: Value(reviewedAt)),
      );
      return (await db.wordDao.getAll()).single;
    }

    test('内容が古いファイルでも、新しい lastReviewedAt だけは取り込む', () async {
      final existing = await seedApple(older);

      final result = await service.importJson(
        _buildExportJson([
          _entryJson(
            word: 'apple',
            meaning: 'リンゴ',
            updatedAt: existing.updatedAt.subtract(const Duration(days: 1)),
            lastReviewedAt: newer,
          ),
        ]),
      );

      // 内容は変えていないので「変更なし」に数える。
      expect(result.updated, 0);
      expect(result.unchanged, 1);
      final after = (await db.wordDao.getAll()).single;
      expect(after.lastReviewedAt, newer);
      expect(after.meaning, 'りんご');
      expect(after.updatedAt, existing.updatedAt);
    });

    test('未回答の単語にもファイル側の lastReviewedAt を取り込む', () async {
      final existing = await seedApple(null);

      await service.importJson(
        _buildExportJson([
          _entryJson(
            word: 'apple',
            meaning: 'りんご',
            updatedAt: existing.updatedAt,
            lastReviewedAt: older,
          ),
        ]),
      );

      expect((await db.wordDao.getAll()).single.lastReviewedAt, older);
    });

    test('ファイル側の lastReviewedAt が古ければ書き換えない', () async {
      final existing = await seedApple(newer);

      await service.importJson(
        _buildExportJson([
          _entryJson(
            word: 'apple',
            meaning: 'りんご',
            updatedAt: existing.updatedAt.subtract(const Duration(days: 1)),
            lastReviewedAt: older,
          ),
        ]),
      );

      expect((await db.wordDao.getAll()).single.lastReviewedAt, newer);
    });

    test('内容がファイル側の勝ちでも、lastReviewedAt は古くしない', () async {
      final existing = await seedApple(newer);

      final result = await service.importJson(
        _buildExportJson([
          _entryJson(
            word: 'apple',
            meaning: 'リンゴ',
            updatedAt: existing.updatedAt.add(const Duration(days: 1)),
            lastReviewedAt: older,
          ),
        ]),
      );

      expect(result.updated, 1);
      final after = (await db.wordDao.getAll()).single;
      expect(after.meaning, 'リンゴ');
      expect(after.lastReviewedAt, newer);
    });
  });

  group('削除ログ', () {
    Future<int> insertWord(String word, {required DateTime updatedAt}) async {
      final id = await db.wordDao.insertWord(
        WordsCompanion(word: Value(word), meaning: const Value('訳')),
      );
      // insertWord は updatedAt を now で上書きするため、狙った時刻に直す。
      await (db.update(db.words)..where((t) => t.id.equals(id))).write(
        WordsCompanion(updatedAt: Value(updatedAt)),
      );
      return id;
    }

    test('ローカルの単語より新しい削除ログはその単語を消す', () async {
      await insertWord('apple', updatedAt: DateTime.utc(2026, 1, 1));

      final result = await service.importJson(
        _buildExportJsonV2(
          words: [],
          deletions: [_deletionJson('apple', DateTime.utc(2026, 2, 1))],
        ),
      );

      expect(result.deleted, 1);
      expect(await db.wordDao.getAll(), isEmpty);
    });

    test('削除ログより後にローカルで編集していれば消さない', () async {
      await insertWord('apple', updatedAt: DateTime.utc(2026, 3, 1));

      final result = await service.importJson(
        _buildExportJsonV2(
          words: [],
          deletions: [_deletionJson('apple', DateTime.utc(2026, 2, 1))],
        ),
      );

      expect(result.deleted, 0);
      expect(await db.wordDao.getAll(), hasLength(1));
    });

    test('ローカルに無い単語の削除ログもログとして取り込む(第 3 の端末へ伝播させる)', () async {
      await service.importJson(
        _buildExportJsonV2(
          words: [],
          deletions: [_deletionJson('apple', DateTime.utc(2026, 2, 1))],
        ),
      );

      final deletions = await db.wordDao.getDeletions();
      expect(deletions.single.word, 'apple');
    });

    test('削除より新しい単語がファイルに載っていれば復活させ、ログは取り消す', () async {
      final result = await service.importJson(
        _buildExportJsonV2(
          words: [
            _entryJson(
              word: 'apple',
              meaning: 'りんご',
              updatedAt: DateTime.utc(2026, 3, 1),
            ),
          ],
          deletions: [_deletionJson('apple', DateTime.utc(2026, 2, 1))],
        ),
      );

      expect(result.added, 1);
      expect(result.deleted, 0);
      expect((await db.wordDao.getAll()).single.word, 'apple');
      expect(await db.wordDao.getDeletions(), isEmpty);
    });

    test('ローカルの編集が削除より新しくても、ファイル側の再登録がさらに新しければ残す', () async {
      await insertWord('apple', updatedAt: DateTime.utc(2026, 3, 1));

      final result = await service.importJson(
        _buildExportJsonV2(
          words: [
            _entryJson(
              word: 'apple',
              meaning: '新しい訳',
              updatedAt: DateTime.utc(2026, 4, 1),
            ),
          ],
          deletions: [_deletionJson('apple', DateTime.utc(2026, 2, 1))],
        ),
      );

      expect(result.updated, 1);
      expect(result.deleted, 0);
      expect((await db.wordDao.getAll()).single.meaning, '新しい訳');
    });

    test('削除ログは大文字小文字・前後空白を無視して突き合わせる', () async {
      await insertWord('Apple', updatedAt: DateTime.utc(2026, 1, 1));

      final result = await service.importJson(
        _buildExportJsonV2(
          words: [],
          deletions: [_deletionJson('  APPLE ', DateTime.utc(2026, 2, 1))],
        ),
      );

      expect(result.deleted, 1);
      expect(await db.wordDao.getAll(), isEmpty);
    });

    test('壊れた削除ログの行は捨てて、単語本体の取り込みは続行する', () async {
      final result = await service.importJson(
        _buildExportJsonV2(
          words: [
            _entryJson(
              word: 'apple',
              meaning: 'りんご',
              updatedAt: DateTime.utc(2026),
            ),
          ],
          deletions: [
            {'word': 'banana'}, // deletedAt 欠落
            'not a map',
          ],
        ),
      );

      expect(result.added, 1);
      expect(await db.wordDao.getDeletions(), isEmpty);
    });

    test('エクスポートには削除ログが含まれる', () async {
      final id = await insertWord('apple', updatedAt: DateTime.utc(2026));
      await db.wordDao.deleteWord(id);

      final decoded =
          jsonDecode(await service.exportJson()) as Map<String, dynamic>;
      final deletions = decoded['deletions'] as List;
      expect(deletions, hasLength(1));
      expect((deletions.single as Map<String, dynamic>)['word'], 'apple');
    });
  });
}

/// version 1(deletions を持たない旧フォーマット)。後方互換の確認を兼ねる。
String _buildExportJson(List<Map<String, dynamic>> words) {
  return jsonEncode({
    'version': 1,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'words': words,
  });
}

String _buildExportJsonV2({
  required List<Map<String, dynamic>> words,
  required List<Object> deletions,
}) {
  return jsonEncode({
    'version': 2,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'words': words,
    'deletions': deletions,
  });
}

Map<String, dynamic> _deletionJson(String word, DateTime deletedAt) {
  return {'word': word, 'deletedAt': deletedAt.toUtc().toIso8601String()};
}

Map<String, dynamic> _entryJson({
  required String word,
  required String meaning,
  required DateTime updatedAt,
  DateTime? lastReviewedAt,
}) {
  return {
    'word': word,
    'japanese': meaning,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'createdAt': updatedAt.toUtc().toIso8601String(),
    if (lastReviewedAt != null)
      'lastReviewedAt': lastReviewedAt.toUtc().toIso8601String(),
  };
}
