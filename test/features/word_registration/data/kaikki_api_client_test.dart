import 'dart:convert';

import 'package:eitangocho/features/word_registration/data/kaikki_api_client.dart';
import 'package:eitangocho/features/word_registration/domain/word_info_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// 実レスポンス(kaikki.org の obtain / monster)から必要な形だけ抜き出した JSONL。
/// 1 行 1 品詞で、sounds には ipa を持たない要素(audio / rhymes)も混ざる。
const monsterJsonl = '''
{"word":"monster","pos":"noun","sounds":[{"tags":["Received-Pronunciation"],"ipa":"/ˈmɒnstə(ɹ)/"},{"ipa":"/ˈmɑnstɚ/","tags":["US"]},{"audio":"en-us-monster.ogg","tags":["US"]},{"rhymes":"-ɒnstə(ɹ)"}],"senses":[{"examples":[{"text":"The Loch Ness monster is a legend.","type":"example"},{"text":"a monster of a wave — Some Author, 1890","type":"quotation"},{"text":"monster truck","type":"example","tags":["collocation"]}]}]}
{"word":"monster","pos":"adj","sounds":[],"senses":[{"examples":[{"text":"They had a monster hit last year.","type":"example"}]}]}
''';

void main() {
  http.Response utf8Response(String body, int status) =>
      http.Response.bytes(utf8.encode(body), status);

  /// 呼ばれた URL のパスを記録しつつ、パスごとにレスポンスを返す MockClient。
  ({KaikkiApiClient client, List<String> paths}) buildClient(
    http.Response Function(String path) respond,
  ) {
    final paths = <String>[];
    return (
      client: KaikkiApiClient(
        MockClient((request) async {
          paths.add(request.url.path);
          return respond(request.url.path);
        }),
      ),
      paths: paths,
    );
  }

  test('JSONL を品詞ごとのエントリにパースする', () async {
    final mock = buildClient((_) => utf8Response(monsterJsonl, 200));

    final json = await mock.client.fetchEntriesJson('monster');
    expect(json, isNotNull);

    final entries = KaikkiApiClient.parseEntries(json!);
    expect(entries, hasLength(2));
    expect(entries.first.pos, 'noun');
    expect(entries.last.pos, 'adj');
    expect(
      mock.paths.single,
      '/dictionary/English/meaning/m/mo/monster.jsonl',
    );
  });

  test('ipa を持たない sounds 要素があってもパースできる', () async {
    final mock = buildClient((_) => utf8Response(monsterJsonl, 200));

    final entries =
        KaikkiApiClient.parseEntries((await mock.client.fetchEntriesJson('monster'))!);

    final ipas = [
      for (final sound in entries.first.sounds)
        if (sound.ipa != null) sound.ipa,
    ];
    expect(ipas, ['/ˈmɒnstə(ɹ)/', '/ˈmɑnstɚ/']);
    expect(entries.first.sounds.firstWhere((s) => s.tags.contains('US')).ipa,
        '/ˈmɑnstɚ/');
  });

  // 引用は長文でキャッシュを膨らませるだけなので保存段階で落とす。
  test('quotation の例文は捨て、example だけ残す', () async {
    final mock = buildClient((_) => utf8Response(monsterJsonl, 200));

    final entries =
        KaikkiApiClient.parseEntries((await mock.client.fetchEntriesJson('monster'))!);

    final texts = [
      for (final sense in entries.first.senses)
        for (final example in sense.examples) example.text,
    ];
    expect(texts, ['The Loch Ness monster is a legend.', 'monster truck']);
  });

  test('大文字小文字を区別するため、404 なら頭大文字で引き直す', () async {
    final mock = buildClient(
      (path) => path.endsWith('/S/Se/September.jsonl')
          ? utf8Response(
              '{"word":"September","pos":"noun","sounds":[{"ipa":"/sɛpˈtɛmbə/"}],"senses":[]}',
              200,
            )
          : utf8Response('not found', 404),
    );

    final json = await mock.client.fetchEntriesJson('september');

    expect(json, isNotNull);
    expect(KaikkiApiClient.parseEntries(json!).single.word, 'September');
    expect(mock.paths, [
      '/dictionary/English/meaning/s/se/september.jsonl',
      '/dictionary/English/meaning/S/Se/September.jsonl',
    ]);
  });

  test('小文字・大文字とも 404 なら未収録(null)', () async {
    final mock = buildClient((_) => utf8Response('not found', 404));

    expect(await mock.client.fetchEntriesJson('asdfghjkl'), isNull);
    expect(mock.paths, hasLength(2));
  });

  test('1 文字の単語もパスを組める', () async {
    final mock = buildClient(
      (_) => utf8Response('{"word":"a","pos":"article","senses":[]}', 200),
    );

    await mock.client.fetchEntriesJson('a');

    expect(mock.paths.single, '/dictionary/English/meaning/a/a/a.jsonl');
  });

  test('壊れた行はその行だけ捨てて続行する', () async {
    final mock = buildClient(
      (_) => utf8Response(
        'これは JSON ではない\n'
        '{"word":"monster","pos":"noun","senses":[]}\n',
        200,
      ),
    );

    final entries =
        KaikkiApiClient.parseEntries((await mock.client.fetchEntriesJson('monster'))!);

    expect(entries.single.pos, 'noun');
  });

  test('本文が空なら未収録(null)', () async {
    final mock = buildClient((_) => utf8Response('', 200));

    expect(await mock.client.fetchEntriesJson('monster'), isNull);
  });

  test('502 は WordInfoException', () async {
    final mock = buildClient((_) => utf8Response('bad gateway', 502));

    expect(
      () => mock.client.fetchEntriesJson('monster'),
      throwsA(isA<WordInfoException>()),
    );
  });

  test('User-Agent を名乗る', () async {
    String? userAgent;
    final client = KaikkiApiClient(
      MockClient((request) async {
        userAgent = request.headers['User-Agent'];
        return utf8Response(monsterJsonl, 200);
      }),
    );

    await client.fetchEntriesJson('monster');

    expect(userAgent, isNotEmpty);
    expect(userAgent, contains('eitangocho'));
  });
}
