import 'dart:convert';

import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/word_registration/data/deepl_client.dart';
import 'package:eitangocho/features/word_registration/data/dictionary_word_info_provider.dart';
import 'package:eitangocho/features/word_registration/data/ejdict_importer.dart';
import 'package:eitangocho/features/word_registration/data/kaikki_api_client.dart';
import 'package:eitangocho/features/word_registration/domain/word_info_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// kaikki の JSONL(1 行 1 品詞)。実レスポンスから必要な形だけ抜き出したもの。
/// - sounds は方言タグ付きが複数、異音表記 `[...]` も混ざる
/// - examples には collocation の断片と、派生語しか含まない文が混ざる
const kaikkiFixture = '''
{"word":"serendipity","pos":"noun","sounds":[{"tags":["Received-Pronunciation"],"ipa":"/ˌsɛɹənˈdɪpɪti/"},{"tags":["US"],"ipa":"/ˌsɛɹənˈdɪpɪɾi/"},{"tags":["US"],"ipa":"[ˌsɛɹənˈdɪpɪɾi]"}],"senses":[{"examples":[{"text":"serendipity value","type":"example","tags":["collocation"]},{"text":"It was serendipity that brought them together.","type":"example"},{"text":"Their meeting was pure serendipity, unplanned and unexpected.","type":"example"}]}]}
{"word":"serendipity","pos":"name","sounds":[],"senses":[]}
''';

void main() {
  late AppDatabase db;
  var kaikkiCallCount = 0;
  var deeplCallCount = 0;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    kaikkiCallCount = 0;
    deeplCallCount = 0;
  });

  tearDown(() async {
    await db.close();
  });

  // http.Response(String) は latin1 でエンコードするため、IPA 記号・日本語を
  // 含むボディは UTF-8 バイト列で返す。
  http.Response utf8Response(String body, int status) =>
      http.Response.bytes(utf8.encode(body), status);

  /// kaikki / DeepL のレスポンスを差し替えて DictionaryWordInfoProvider を組み立てる。
  DictionaryWordInfoProvider buildProvider({
    http.Response Function()? kaikkiResponse,
    http.Response Function()? deeplResponse,
    String deeplApiKey = '',
  }) {
    return DictionaryWordInfoProvider(
      kaikkiClient: KaikkiApiClient(
        MockClient((_) async {
          kaikkiCallCount++;
          return kaikkiResponse != null
              ? kaikkiResponse()
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

  test('kaikki・EJDict 両ヒット: 全項目をマッピングし DeepL で例文を和訳する', () async {
    await seedEjdict({'serendipity': '思わぬ発見'});
    final provider = buildProvider(
      kaikkiResponse: () => utf8Response(kaikkiFixture, 200),
      deeplResponse: () =>
          utf8Response('{"translations":[{"text":"二人を巡り合わせたのは偶然だった。"}]}', 200),
      deeplApiKey: 'key',
    );

    final info = await provider.fetch('serendipity');

    expect(info, isNotNull);
    expect(info!.word, 'serendipity');
    expect(info.japanese, '思わぬ発見');
    // name は other に落ちる
    expect(info.partsOfSpeech, [PartOfSpeech.noun, PartOfSpeech.other]);
    expect(info.exampleJa, '二人を巡り合わせたのは偶然だった。');
  });

  test('IPA は米音(US / General-American)を優先し、音素表記だけを使う', () async {
    final provider = buildProvider(
      kaikkiResponse: () => utf8Response(kaikkiFixture, 200),
    );

    final info = await provider.fetch('serendipity');

    expect(info!.ipa, '/ˌsɛɹənˈdɪpɪɾi/');
  });

  test('方言タグが無い語は最初の IPA を使う', () async {
    final provider = buildProvider(
      kaikkiResponse: () => utf8Response(
        '{"word":"obtain","pos":"verb","sounds":[{"ipa":"/əbˈteɪn/"}],"senses":[]}',
        200,
      ),
    );

    expect((await provider.fetch('obtain'))!.ipa, '/əbˈteɪn/');
  });

  test('例文は断片を避け、見出し語を含む中から最短を選ぶ', () async {
    final provider = buildProvider(
      kaikkiResponse: () => utf8Response(kaikkiFixture, 200),
    );

    final info = await provider.fetch('serendipity');

    // collocation の "serendipity value" と、より長い 2 件目は選ばれない
    expect(info!.exampleEn, 'It was serendipity that brought them together.');
  });

  test('見出し語を含まない例文しか無ければ例文は空', () async {
    final provider = buildProvider(
      kaikkiResponse: () => utf8Response(
        '{"word":"negligible","pos":"adj","senses":[{"examples":['
        '{"text":"He was negligent of his duties.","type":"example"}]}]}',
        200,
      ),
    );

    expect((await provider.fetch('negligible'))!.exampleEn, isEmpty);
  });

  test('kaikki 未収録・EJDict のみヒット: japanese のみの WordInfo を返す', () async {
    await seedEjdict({'milksop': '意気地なし'});
    final provider = buildProvider();

    final info = await provider.fetch('milksop');

    expect(info, isNotNull);
    expect(info!.japanese, '意気地なし');
    expect(info.ipa, isEmpty);
    expect(info.exampleEn, isEmpty);
    expect(info.partsOfSpeech, isEmpty);
  });

  test('kaikki・EJDict 両 miss: null(未収録)', () async {
    final provider = buildProvider();

    expect(await provider.fetch('zzzzz'), isNull);
  });

  test('audioUrl は取得しない(発音は Google 翻訳リンクに一本化)', () async {
    final provider = buildProvider(
      kaikkiResponse: () => utf8Response(kaikkiFixture, 200),
    );

    expect((await provider.fetch('serendipity'))!.audioUrl, isEmpty);
  });

  test('大文字・空白は正規化してから検索する', () async {
    await seedEjdict({'apple': 'リンゴ'});
    final provider = buildProvider();

    final info = await provider.fetch('  Apple ');

    expect(info?.word, 'apple');
    expect(info?.japanese, 'リンゴ');
  });

  test('成功レスポンスはキャッシュされ、2 回目は取得しない', () async {
    final provider = buildProvider(
      kaikkiResponse: () => utf8Response(kaikkiFixture, 200),
    );

    await provider.fetch('serendipity');
    await provider.fetch('serendipity');

    expect(kaikkiCallCount, 1);
    // 生の JSONL ではなく、正規化した JSON 配列が入る
    final cached = await db.dictionaryCacheDao.find('serendipity');
    expect(cached, isNotNull);
    expect(KaikkiApiClient.parseEntries(cached!), hasLength(2));
  });

  test('未収録(404)はキャッシュしない', () async {
    final provider = buildProvider();

    await provider.fetch('zzzzz');

    expect(await db.dictionaryCacheDao.find('zzzzz'), isNull);
  });

  // Free Dictionary は common word でも 502 を返すことがあり、当時は
  // 取得失敗で登録フロー全体が失敗していた。EJDict の訳だけでも登録できる。
  test('kaikki が 502 でも EJDict がヒットすれば例外を投げず続行する', () async {
    await seedEjdict({'phrase': '句、成句'});
    final provider = buildProvider(
      kaikkiResponse: () => http.Response('bad gateway', 502),
    );

    final info = await provider.fetch('phrase');

    expect(info, isNotNull);
    expect(info!.japanese, '句、成句');
    expect(info.ipa, isEmpty);
  });

  test('kaikki が 502 で EJDict も miss なら WordInfoException', () async {
    final provider = buildProvider(
      kaikkiResponse: () => http.Response('bad gateway', 502),
    );

    expect(
      () => provider.fetch('zzzzz'),
      throwsA(isA<WordInfoException>()),
    );
  });

  test('DeepL キー未設定なら翻訳を呼ばず exampleJa は空', () async {
    final provider = buildProvider(
      kaikkiResponse: () => utf8Response(kaikkiFixture, 200),
    );

    final info = await provider.fetch('serendipity');

    expect(deeplCallCount, 0);
    expect(info!.exampleJa, isEmpty);
  });

  test('DeepL 失敗(キー不正)でも throw せず exampleJa 空で続行する', () async {
    final provider = buildProvider(
      kaikkiResponse: () => utf8Response(kaikkiFixture, 200),
      deeplApiKey: 'bad-key',
    );

    final info = await provider.fetch('serendipity');

    expect(deeplCallCount, 1);
    expect(info!.exampleJa, isEmpty);
    expect(info.exampleEn, 'It was serendipity that brought them together.');
  });
}
