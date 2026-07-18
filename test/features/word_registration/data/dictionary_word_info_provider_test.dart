import 'dart:convert';

import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/word_registration/data/deepl_client.dart';
import 'package:eitangocho/features/word_registration/data/dictionary_word_info_provider.dart';
import 'package:eitangocho/features/word_registration/data/ejdict_importer.dart';
import 'package:eitangocho/features/word_registration/data/free_dictionary_api_client.dart';
import 'package:eitangocho/features/word_registration/domain/word_info_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const fdFixture = '''
[
  {
    "word": "serendipity",
    "phonetic": "/ˌsɛ.ɹən.ˈdɪ.pɪ.ti/",
    "phonetics": [
      {"text": "/ˌsɛ.ɹən.ˈdɪ.pɪ.ti/", "audio": "https://example.com/a.mp3"}
    ],
    "meanings": [
      {
        "partOfSpeech": "noun",
        "definitions": [{"definition": "...", "example": "A lucky find."}]
      },
      {
        "partOfSpeech": "pronoun",
        "definitions": [{"definition": "..."}]
      }
    ]
  }
]
''';

void main() {
  late AppDatabase db;
  var fdCallCount = 0;
  var deeplCallCount = 0;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fdCallCount = 0;
    deeplCallCount = 0;
  });

  tearDown(() async {
    await db.close();
  });

  // http.Response(String) は latin1 でエンコードするため、IPA 記号・日本語を
  // 含むボディは UTF-8 バイト列で返す。
  http.Response utf8Response(String body, int status) =>
      http.Response.bytes(utf8.encode(body), status);

  /// FD / DeepL のレスポンスを差し替えて DictionaryWordInfoProvider を組み立てる。
  DictionaryWordInfoProvider buildProvider({
    http.Response Function()? fdResponse,
    http.Response Function()? deeplResponse,
    String deeplApiKey = '',
  }) {
    return DictionaryWordInfoProvider(
      freeDictionaryClient: FreeDictionaryApiClient(
        MockClient((_) async {
          fdCallCount++;
          return fdResponse != null
              ? fdResponse()
              : http.Response('not found', 404);
        }),
      ),
      deeplClient: DeeplClient(
        MockClient((_) async {
          deeplCallCount++;
          return deeplResponse != null
              ? deeplResponse()
              : http.Response('forbidden', 403);
        }),
      ),
      cacheDao: db.dictionaryCacheDao,
      ejdictDao: db.ejdictDao,
      ensureEjdictImported: () async {},
      getDeeplApiKey: () async => deeplApiKey,
    );
  }

  Future<void> seedEjdict(Map<String, String> entries) =>
      db.ejdictDao.bulkInsert(parseEjdict(
        entries.entries.map((e) => '${e.key}\t${e.value}').join('\n'),
      ));

  test('FD・EJDict 両ヒット: 全項目をマッピングし DeepL で例文を和訳する', () async {
    await seedEjdict({'serendipity': '思わぬ発見'});
    final provider = buildProvider(
      fdResponse: () => utf8Response(fdFixture, 200),
      deeplResponse: () =>
          utf8Response('{"translations":[{"text":"幸運な発見。"}]}', 200),
      deeplApiKey: 'key',
    );

    final info = await provider.fetch('serendipity');

    expect(info, isNotNull);
    expect(info!.word, 'serendipity');
    expect(info.ipa, '/ˌsɛ.ɹən.ˈdɪ.pɪ.ti/');
    expect(info.audioUrl, 'https://example.com/a.mp3');
    // pronoun は other に落ち、noun と重複排除して 2 件
    expect(info.partsOfSpeech, [PartOfSpeech.noun, PartOfSpeech.other]);
    expect(info.japanese, '思わぬ発見');
    expect(info.exampleEn, 'A lucky find.');
    expect(info.exampleJa, '幸運な発見。');
  });

  test('FD 未収録・EJDict のみヒット: japanese のみの WordInfo を返す', () async {
    await seedEjdict({'milksop': '意気地なし'});
    final provider = buildProvider();

    final info = await provider.fetch('milksop');

    expect(info, isNotNull);
    expect(info!.japanese, '意気地なし');
    expect(info.ipa, isEmpty);
    expect(info.exampleEn, isEmpty);
    expect(info.audioUrl, isEmpty);
    expect(info.partsOfSpeech, isEmpty);
  });

  test('FD・EJDict 両 miss: null(未収録)', () async {
    final provider = buildProvider();

    expect(await provider.fetch('zzzzz'), isNull);
  });

  test('大文字・空白は正規化してから検索する', () async {
    await seedEjdict({'apple': 'リンゴ'});
    final provider = buildProvider();

    final info = await provider.fetch('  Apple ');

    expect(info?.word, 'apple');
    expect(info?.japanese, 'リンゴ');
  });

  test('成功レスポンスはキャッシュされ、2 回目は API を呼ばない', () async {
    final provider = buildProvider(
      fdResponse: () => utf8Response(fdFixture, 200),
    );

    await provider.fetch('serendipity');
    await provider.fetch('serendipity');

    expect(fdCallCount, 1);
    expect(await db.dictionaryCacheDao.find('serendipity'), fdFixture);
  });

  test('404(未収録)はキャッシュしない', () async {
    final provider = buildProvider();

    await provider.fetch('zzzzz');

    expect(await db.dictionaryCacheDao.find('zzzzz'), isNull);
  });

  test('FD が 500 なら WordInfoException を投げる', () async {
    final provider = buildProvider(
      fdResponse: () => http.Response('error', 500),
    );

    expect(
      () => provider.fetch('apple'),
      throwsA(isA<WordInfoException>()),
    );
  });

  test('DeepL キー未設定なら翻訳を呼ばず exampleJa は空', () async {
    final provider = buildProvider(
      fdResponse: () => utf8Response(fdFixture, 200),
    );

    final info = await provider.fetch('serendipity');

    expect(deeplCallCount, 0);
    expect(info!.exampleJa, isEmpty);
  });

  test('DeepL 失敗(キー不正)でも throw せず exampleJa 空で続行する', () async {
    final provider = buildProvider(
      fdResponse: () => utf8Response(fdFixture, 200),
      deeplApiKey: 'bad-key',
    );

    final info = await provider.fetch('serendipity');

    expect(deeplCallCount, 1);
    expect(info!.exampleJa, isEmpty);
    expect(info.exampleEn, 'A lucky find.');
  });
}
