import 'dart:convert';

import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/word_registration/data/deepl_client.dart';
import 'package:eitangocho/features/word_registration/data/dictionary_word_info_provider.dart';
import 'package:eitangocho/features/word_registration/data/ejdict_importer.dart';
import 'package:eitangocho/features/word_registration/data/kaikki_api_client.dart';
import 'package:eitangocho/features/word_registration/data/tatoeba_api_client.dart';
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

/// 句動詞の実レスポンス(`give up`)から translations だけ抜き出したもの。
/// 「諦める」は語義違いで 2 件来る(畳んで 1 つにする)。
const giveUpJsonl = '''
{"word":"give up","pos":"verb","senses":[],"translations":[{"lang":"Japanese","code":"ja","lang_code":"ja","sense":"surrender","alt":"こうふくする","roman":"kōfuku suru","word":"降服する"},{"lang":"Japanese","code":"ja","lang_code":"ja","sense":"stop, quit, desist","roman":"akirameru","word":"諦める"},{"lang":"Japanese","code":"ja","lang_code":"ja","sense":"abandon","alt":"あきらめる","roman":"akirameru","word":"諦める"},{"lang":"Japanese","code":"ja","lang_code":"ja","sense":"abandon","roman":"yameru","word":"やめる"}]}
''';

void main() {
  late AppDatabase db;
  var kaikkiCallCount = 0;
  var tatoebaCallCount = 0;
  var deeplCallCount = 0;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    kaikkiCallCount = 0;
    tatoebaCallCount = 0;
    deeplCallCount = 0;
  });

  tearDown(() async {
    await db.close();
  });

  // http.Response(String) は latin1 でエンコードするため、IPA 記号・日本語を
  // 含むボディは UTF-8 バイト列で返す。
  http.Response utf8Response(String body, int status) =>
      http.Response.bytes(utf8.encode(body), status);

  /// Tatoeba のヒット 1 件分のレスポンス。
  String tatoebaResponse(String en, String ja) => jsonEncode({
        'data': [
          {
            'text': en,
            'translations': [
              {'lang': 'jpn', 'text': ja},
            ],
          },
        ],
      });

  /// kaikki / Tatoeba / DeepL のレスポンスを差し替えて
  /// DictionaryWordInfoProvider を組み立てる。
  DictionaryWordInfoProvider buildProvider({
    http.Response Function()? kaikkiResponse,
    http.Response Function()? tatoebaResponseFn,
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
      tatoebaClient: TatoebaApiClient(
        MockClient((_) async {
          tatoebaCallCount++;
          return tatoebaResponseFn != null
              ? tatoebaResponseFn()
              : utf8Response('{"data":[]}', 200);
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

  // 和訳が対で付いてくるうえ、kaikki の例文より単語帳向きなため。
  test('Tatoeba の例文は kaikki の例文より優先される', () async {
    final provider = buildProvider(
      kaikkiResponse: () => utf8Response(kaikkiFixture, 200),
      tatoebaResponseFn: () => utf8Response(
        tatoebaResponse('What a serendipity!', 'なんという偶然！'),
        200,
      ),
    );

    final info = await provider.fetch('serendipity');

    expect(info!.exampleEn, 'What a serendipity!');
    expect(info.exampleJa, 'なんという偶然！');
  });

  test('Tatoeba が空振りなら kaikki の例文を使い、和訳は空のまま', () async {
    final provider = buildProvider(
      kaikkiResponse: () => utf8Response(kaikkiFixture, 200),
    );

    final info = await provider.fetch('serendipity');

    expect(tatoebaCallCount, 1);
    expect(info!.exampleEn, 'It was serendipity that brought them together.');
    expect(info.exampleJa, isEmpty);
  });

  test('Tatoeba で和訳が取れたら DeepL は呼ばない', () async {
    final provider = buildProvider(
      kaikkiResponse: () => utf8Response(kaikkiFixture, 200),
      tatoebaResponseFn: () => utf8Response(
        tatoebaResponse('What a serendipity!', 'なんという偶然！'),
        200,
      ),
      deeplApiKey: 'key',
    );

    await provider.fetch('serendipity');

    expect(deeplCallCount, 0);
  });

  test('kaikki が未収録でも Tatoeba に例文があれば拾う', () async {
    await seedEjdict({'serendipity': '思わぬ発見'});
    final provider = buildProvider(
      tatoebaResponseFn: () => utf8Response(
        tatoebaResponse('What a serendipity!', 'なんという偶然！'),
        200,
      ),
    );

    final info = await provider.fetch('serendipity');

    expect(info!.exampleEn, 'What a serendipity!');
    expect(info.ipa, isEmpty);
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

  // 句動詞は EJDict に無いので、ここが唯一の日本語訳の出所になる。
  test('EJDict が未収録なら kaikki の訳語を日本語訳に使う', () async {
    final provider = buildProvider(
      kaikkiResponse: () => utf8Response(giveUpJsonl, 200),
    );

    final info = await provider.fetch('give up');

    // 語義ごとに重複する「諦める」は 1 つに畳み、EJDict と同じ区切りで繋ぐ。
    expect(info!.japanese, '降服する / 諦める / やめる');
  });

  test('EJDict がヒットすれば kaikki の訳語は使わない', () async {
    await seedEjdict({'give up': 'あきらめる(EJDict 側)'});
    final provider = buildProvider(
      kaikkiResponse: () => utf8Response(giveUpJsonl, 200),
    );

    final info = await provider.fetch('give up');

    expect(info!.japanese, 'あきらめる(EJDict 側)');
  });

  test('訳語が多い語は打ち切る(必須項目の欄が長大にならないように)', () async {
    final many = [
      for (var i = 0; i < 12; i++)
        '{"lang_code":"ja","word":"訳$i"}',
    ].join(',');
    final provider = buildProvider(
      kaikkiResponse: () => utf8Response(
        '{"word":"x","pos":"verb","senses":[],"translations":[$many]}',
        200,
      ),
    );

    final info = await provider.fetch('x');

    expect(info!.japanese.split(' / '), hasLength(5));
  });

  test('日本語以外の訳語はキャッシュにも日本語訳にも残さない', () async {
    final provider = buildProvider(
      kaikkiResponse: () => utf8Response(
        '{"word":"x","pos":"verb","senses":[],"translations":['
        '{"lang_code":"fr","word":"abandonner"},'
        '{"lang_code":"ja","word":"諦める"}]}',
        200,
      ),
    );

    final info = await provider.fetch('x');

    expect(info!.japanese, '諦める');
    expect(await db.dictionaryCacheDao.find('x'), isNot(contains('abandonner')));
  });

  test('kaikki・EJDict 両 miss で例文も無ければ null(未収録)', () async {
    final provider = buildProvider();

    expect(await provider.fetch('zzzzz'), isNull);
  });

  // kaikki の見出しが入力とずれる句(`run out of` は Wiktionary が `run out`)
  // では、Tatoeba だけが自動入力の出所になる。ここで打ち切ると空のフォームに
  // なってしまう。
  test('kaikki・EJDict 両 miss でも Tatoeba に例文があれば返す', () async {
    final provider = buildProvider(
      tatoebaResponseFn: () => utf8Response(
        tatoebaResponse("We've run out of soap.", '石鹸がないです。'),
        200,
      ),
    );

    final info = await provider.fetch('run out of');

    expect(info, isNotNull);
    expect(info!.exampleEn, "We've run out of soap.");
    expect(info.exampleJa, '石鹸がないです。');
    // 埋まるのは例文だけ。訳が空なので登録フォームは警告バナーを出す。
    expect(info.japanese, isEmpty);
    expect(info.partsOfSpeech, isEmpty);
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

  // キャッシュは toJson / fromJson を通るため、キー名がずれると 2 回目だけ
  // 訳が消える(1 回目は生レスポンスから読むので気付けない)。
  test('キャッシュから読んだ 2 回目も kaikki の訳語を返す', () async {
    final provider = buildProvider(
      kaikkiResponse: () => utf8Response(giveUpJsonl, 200),
    );

    await provider.fetch('give up');
    final second = await provider.fetch('give up');

    expect(kaikkiCallCount, 1);
    expect(second!.japanese, '降服する / 諦める / やめる');
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
