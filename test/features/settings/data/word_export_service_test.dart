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
        japanese: Value('偶然の幸運'),
        ipa: Value('/ˌserənˈdɪpəti/'),
        partsOfSpeech: Value([PartOfSpeech.noun]),
        exampleEn: Value('Meeting her was pure serendipity.'),
        exampleJa: Value('彼女に出会えたのはまったくの偶然の幸運だった。'),
      ),
    );

    final json = await service.exportJson();
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    expect(decoded['version'], 1);
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
    expect(imported.japanese, '偶然の幸運');
    expect(imported.ipa, '/ˌserənˈdɪpəti/');
    expect(imported.partsOfSpeech, [PartOfSpeech.noun]);
    expect(imported.exampleEn, 'Meeting her was pure serendipity.');
  });

  test('ファイル側 updatedAt が新しければ上書きされる', () async {
    final id = await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
    );
    final existing = (await db.wordDao.getAll()).single;
    final newerUpdatedAt = existing.updatedAt.add(const Duration(days: 1));

    final json = _buildExportJson([
      _entryJson(word: 'apple', japanese: 'リンゴ', updatedAt: newerUpdatedAt),
    ]);

    final result = await service.importJson(json);
    expect(result.added, 0);
    expect(result.updated, 1);
    expect(result.unchanged, 0);

    final after = await db.wordDao.getAll();
    expect(after, hasLength(1));
    expect(after.single.id, id);
    expect(after.single.japanese, 'リンゴ');
    // word 表記と createdAt は DB 側を維持する。
    expect(after.single.word, 'apple');
  });

  test('ファイル側 updatedAt が古い・同時刻なら上書きされない(変更なし)', () async {
    final id = await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
    );
    final existing = (await db.wordDao.getAll()).single;
    final olderUpdatedAt = existing.updatedAt.subtract(const Duration(days: 1));

    final json = _buildExportJson([
      _entryJson(word: 'apple', japanese: 'リンゴ', updatedAt: olderUpdatedAt),
    ]);

    final result = await service.importJson(json);
    expect(result.updated, 0);
    expect(result.unchanged, 1);

    final after = await db.wordDao.getAll();
    expect(after.single.id, id);
    expect(after.single.japanese, 'りんご');
  });

  test('単語の照合は trim + 小文字化で行い、DB 側の表記を維持する', () async {
    await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
    );
    final existing = (await db.wordDao.getAll()).single;
    final newerUpdatedAt = existing.updatedAt.add(const Duration(days: 1));

    final json = _buildExportJson([
      _entryJson(word: ' Apple ', japanese: 'リンゴ', updatedAt: newerUpdatedAt),
    ]);

    final result = await service.importJson(json);
    expect(result.updated, 1);

    final after = await db.wordDao.getAll();
    expect(after, hasLength(1));
    expect(after.single.word, 'apple');
    expect(after.single.japanese, 'リンゴ');
  });

  test('word・japanese の欠落や型不正・空文字はスキップして続行する', () async {
    final json = jsonEncode({
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'words': [
        {'japanese': '訳のみ'}, // word 欠落
        {'word': 'no-japanese'}, // japanese 欠落
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
      'version': 2,
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
      _entryJson(word: 'apple', japanese: '古い訳', updatedAt: older),
      _entryJson(word: 'apple', japanese: '新しい訳', updatedAt: newer),
    ]);

    final result = await service.importJson(json);
    expect(result.added, 1);
    expect(result.unchanged, 1);

    final words = await db.wordDao.getAll();
    expect(words, hasLength(1));
    expect(words.single.japanese, '新しい訳');
  });
}

String _buildExportJson(List<Map<String, dynamic>> words) {
  return jsonEncode({
    'version': 1,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'words': words,
  });
}

Map<String, dynamic> _entryJson({
  required String word,
  required String japanese,
  required DateTime updatedAt,
}) {
  return {
    'word': word,
    'japanese': japanese,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'createdAt': updatedAt.toUtc().toIso8601String(),
  };
}
