import 'dart:convert';

import 'package:eitangocho/features/word_registration/data/tatoeba_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// 実レスポンスの形。translations は `trans:lang` 指定時のみ入る平坦な配列で、
/// 指定しないと null になる。
String responseOf(List<(String, String?)> sentences) => jsonEncode({
      'data': [
        for (final (text, ja) in sentences)
          {
            'text': text,
            'lang': 'eng',
            'translations':
                ja == null ? null : [
                  {'lang': 'jpn', 'text': ja},
                ],
          },
      ],
    });

void main() {
  http.Response utf8Response(String body, int status) =>
      http.Response.bytes(utf8.encode(body), status);

  ({TatoebaApiClient client, List<Uri> requests}) buildClient(
    http.Response Function() respond,
  ) {
    final requests = <Uri>[];
    return (
      client: TatoebaApiClient(
        MockClient((request) async {
          requests.add(request.url);
          return respond();
        }),
      ),
      requests: requests,
    );
  }

  test('和訳付きの文を英日ペアで返す', () async {
    final mock = buildClient(
      () => utf8Response(
        responseOf([('Tom obtained a gun.', 'トムは銃を手に入れた。')]),
        200,
      ),
    );

    final example = await mock.client.findExample('obtain');

    expect(example, isNotNull);
    expect(example!.en, 'Tom obtained a gun.');
    expect(example.ja, 'トムは銃を手に入れた。');
  });

  test('必要なクエリを組み立てる(sort が無いと 400 になる)', () async {
    final mock = buildClient(() => utf8Response(responseOf([]), 200));

    await mock.client.findExample('obtain');

    final uri = mock.requests.single;
    expect(uri.host, 'api.tatoeba.org');
    expect(uri.path, '/unstable/sentences');
    expect(uri.queryParameters, {
      'lang': 'eng',
      'q': 'obtain',
      'trans:lang': 'jpn',
      'sort': 'relevance',
      'limit': '10',
    });
  });

  // 最短だけで選ぶと monster に「Monster!」が付いてしまう。
  test('1〜2 語の文より、3 語以上の文を優先する', () async {
    final mock = buildClient(
      () => utf8Response(
        responseOf([
          ('Monster!', '化け物！'),
          ("There's a monster in my closet.", '押し入れに怪物がいる。'),
          ('I saw a monster in the woods last night.', '昨夜森で怪物を見た。'),
        ]),
        200,
      ),
    );

    final example = await mock.client.findExample('monster');

    expect(example!.en, "There's a monster in my closet.");
  });

  // 語数で足切りすると、短文しか無い語で和訳付きの例文を丸ごと失う。
  test('3 語以上の候補が無ければ、短い中でいちばん語数の多い文に降りる', () async {
    final mock = buildClient(
      () => utf8Response(
        responseOf([
          ('Ghosts!', '幽霊だ！'),
          ('Ghosts exist.', '幽霊は存在する。'),
        ]),
        200,
      ),
    );

    final example = await mock.client.findExample('ghost');

    expect(example!.en, 'Ghosts exist.');
  });

  test('条件を満たす中では最短の文を選ぶ', () async {
    final mock = buildClient(
      () => utf8Response(
        responseOf([
          ('Tom obtained a firearm from the shop yesterday.', 'トムは昨日店で銃を買った。'),
          ('Tom obtained a gun.', 'トムは銃を手に入れた。'),
        ]),
        200,
      ),
    );

    expect((await mock.client.findExample('obtain'))!.en, 'Tom obtained a gun.');
  });

  // Tatoeba の検索はステミングするため、これを弾けないと別の単語の例文が入る。
  test('見出し語の派生語しか含まない文は採用しない', () async {
    final mock = buildClient(
      () => utf8Response(
        responseOf([
          ("I'm displeased with your negligence.", '僕は君の怠慢が気に入らない。'),
          ('He was negligent of his duties.', '彼は職務怠慢だった。'),
        ]),
        200,
      ),
    );

    expect(await mock.client.findExample('negligible'), isNull);
  });

  // 句動詞は語形フィルタが複合語を扱えないと候補が全滅する。
  test('句動詞は語順が変わった文も採用する', () async {
    final mock = buildClient(
      () => utf8Response(
        responseOf([
          ('He put on a coat.', '彼はコートを着た。'),
          ('The wedding was put off.', '結婚式は延期された。'),
        ]),
        200,
      ),
    );

    final example = await mock.client.findExample('put off');

    expect(example!.en, 'The wedding was put off.');
  });

  test('和訳が無い文は採用しない', () async {
    final mock = buildClient(
      () => utf8Response(
        responseOf([
          ('Tom obtained a gun.', null),
          ('Tom obtained a firearm.', 'トムは銃を手に入れた。'),
        ]),
        200,
      ),
    );

    expect((await mock.client.findExample('obtain'))!.en, 'Tom obtained a firearm.');
  });

  test('ヒットしなければ null', () async {
    final mock = buildClient(() => utf8Response(responseOf([]), 200));

    expect(await mock.client.findExample('zzzzz'), isNull);
  });

  // 例文は補助情報なので、失敗しても登録フローを止めない。
  test('通信失敗・非 200・壊れたレスポンスはすべて null', () async {
    final serverError = buildClient(() => http.Response('error', 500));
    expect(await serverError.client.findExample('obtain'), isNull);

    final broken = buildClient(() => utf8Response('not json', 200));
    expect(await broken.client.findExample('obtain'), isNull);

    final throwing = TatoebaApiClient(
      MockClient((_) async => throw http.ClientException('boom')),
    );
    expect(await throwing.findExample('obtain'), isNull);
  });

  test('空文字は問い合わせない', () async {
    final mock = buildClient(() => utf8Response(responseOf([]), 200));

    expect(await mock.client.findExample('  '), isNull);
    expect(mock.requests, isEmpty);
  });
}
