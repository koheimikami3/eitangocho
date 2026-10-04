import 'dart:convert';

import 'package:eitangocho/features/settings/domain/translation_language.dart';
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
        'translations': ja == null
            ? null
            : [
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

    final example = await mock.client.findExample(
      'obtain',
      TranslationLanguage.ja,
    );

    expect(example, isNotNull);
    expect(example!.en, 'Tom obtained a gun.');
    expect(example.translation, 'トムは銃を手に入れた。');
  });

  test('必要なクエリを組み立てる(sort が無いと 400 になる)', () async {
    final mock = buildClient(() => utf8Response(responseOf([]), 200));

    await mock.client.findExample('obtain', TranslationLanguage.ja);

    final uri = mock.requests.single;
    expect(uri.host, 'api.tatoeba.org');
    expect(uri.path, '/unstable/sentences');
    expect(uri.queryParameters, {
      'lang': 'eng',
      'q': 'obtain',
      'trans:lang': 'jpn',
      'sort': 'relevance',
      'limit': '30',
    });
  });

  // 最短だけで選ぶと monster に「Monster!」が付いてしまう。
  test('下限に満たない文より、下限以上の文を優先する', () async {
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

    final example = await mock.client.findExample(
      'monster',
      TranslationLanguage.ja,
    );

    expect(example!.en, "There's a monster in my closet.");
  });

  // 語数で足切りすると、短文しか無い語で和訳付きの例文を丸ごと失う。
  test('下限以上の候補が無ければ、短い中でいちばん語数の多い文に降りる', () async {
    final mock = buildClient(
      () => utf8Response(
        responseOf([('Ghosts!', '幽霊だ！'), ('Ghosts exist.', '幽霊は存在する。')]),
        200,
      ),
    );

    final example = await mock.client.findExample(
      'ghost',
      TranslationLanguage.ja,
    );

    expect(example!.en, 'Ghosts exist.');
  });

  test('下限を満たす中では最短の文を選ぶ', () async {
    final mock = buildClient(
      () => utf8Response(
        responseOf([
          (
            'Tom obtained a firearm from the shop in town yesterday.',
            'トムは昨日町の店で銃を買った。',
          ),
          ('How much money have you obtained?', 'あなたはどれくらいのお金を手にしましたか。'),
        ]),
        200,
      ),
    );

    expect(
      (await mock.client.findExample('obtain', TranslationLanguage.ja))!.en,
      'How much money have you obtained?',
    );
  });

  // 下限は語数で見ているので、長短の比較も語数で揃える。文字数で比べると、
  // 語数の少ない長い単語の文が「長い文」として勝ってしまう。
  test('長短は文字数ではなく語数で比べる', () async {
    final mock = buildClient(
      () => utf8Response(
        responseOf([
          // 4 語だが 40 文字(文字数で比べるとこちらが最長になる)
          ('Apples contain considerable antioxidants.', 'りんごには相当量の抗酸化物質が含まれる。'),
          // 5 語 20 文字
          ('I want an apple now.', 'りんごが今すぐ欲しい。'),
        ]),
        200,
      ),
    );

    // どちらも下限に届かないので降格し、語数の多い方を採る。
    expect(
      (await mock.client.findExample('apple', TranslationLanguage.ja))!.en,
      'I want an apple now.',
    );
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

    expect(
      await mock.client.findExample('negligible', TranslationLanguage.ja),
      isNull,
    );
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

    final example = await mock.client.findExample(
      'put off',
      TranslationLanguage.ja,
    );

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

    expect(
      (await mock.client.findExample('obtain', TranslationLanguage.ja))!.en,
      'Tom obtained a firearm.',
    );
  });

  test('ヒットしなければ null', () async {
    final mock = buildClient(() => utf8Response(responseOf([]), 200));

    expect(
      await mock.client.findExample('zzzzz', TranslationLanguage.ja),
      isNull,
    );
  });

  // 例文は補助情報なので、失敗しても登録フローを止めない。
  test('通信失敗・非 200・壊れたレスポンスはすべて null', () async {
    final serverError = buildClient(() => http.Response('error', 500));
    expect(
      await serverError.client.findExample('obtain', TranslationLanguage.ja),
      isNull,
    );

    final broken = buildClient(() => utf8Response('not json', 200));
    expect(
      await broken.client.findExample('obtain', TranslationLanguage.ja),
      isNull,
    );

    final throwing = TatoebaApiClient(
      MockClient((_) async => throw http.ClientException('boom')),
    );
    expect(
      await throwing.findExample('obtain', TranslationLanguage.ja),
      isNull,
    );
  });

  test('空文字は問い合わせない', () async {
    final mock = buildClient(() => utf8Response(responseOf([]), 200));

    expect(await mock.client.findExample('  ', TranslationLanguage.ja), isNull);
    expect(mock.requests, isEmpty);
  });

  group('繁体字中国語', () {
    // cmn には繁体字と簡体字の訳が混ざって返る(script で区別される)。
    String chineseResponse() => jsonEncode({
      'data': [
        {
          'text': 'They achieved their goal.',
          'lang': 'eng',
          'translations': [
            {'lang': 'cmn', 'script': 'Hans', 'text': '他们达到了目标。'},
          ],
        },
        {
          'text': 'How did you achieve that so quickly?',
          'lang': 'eng',
          'translations': [
            {'lang': 'cmn', 'script': 'Hans', 'text': '你怎么这么快就完成了？'},
            {'lang': 'cmn', 'script': 'Hant', 'text': '你怎麼這麼快就完成了？'},
          ],
        },
      ],
    });

    test('cmn の訳を求め、繁体字の訳がある文だけを採る', () async {
      final mock = buildClient(() => utf8Response(chineseResponse(), 200));

      final example = await mock.client.findExample(
        'achieve',
        TranslationLanguage.zhHant,
      );

      expect(mock.requests.single.queryParameters['trans:lang'], 'cmn');
      expect(example!.en, 'How did you achieve that so quickly?');
      expect(example.translation, '你怎麼這麼快就完成了？');
    });

    test('日本語の訳しか無い文は採らない', () async {
      final mock = buildClient(
        () => utf8Response(
          responseOf([('Tom obtained a gun.', 'トムは銃を手に入れた。')]),
          200,
        ),
      );

      expect(
        await mock.client.findExample('obtain', TranslationLanguage.zhHant),
        isNull,
      );
    });
  });
}
