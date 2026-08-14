import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('チップの並びは 名詞 → 動詞 → 形容詞 → 副詞 → その他', () {
    expect(PartOfSpeech.values.map((p) => p.label), [
      '名詞',
      '動詞',
      '形容詞',
      '副詞',
      'その他',
    ]);
  });

  group('ordered', () {
    test('基準にある品詞は基準の並びを保つ(辞書が返した主用法が先頭に残る)', () {
      const basedOn = [PartOfSpeech.verb, PartOfSpeech.noun];

      expect({PartOfSpeech.noun, PartOfSpeech.verb}.ordered(basedOn: basedOn), [
        PartOfSpeech.verb,
        PartOfSpeech.noun,
      ]);
    });

    test('基準に無い品詞は enum の宣言順で後ろに付く', () {
      const basedOn = [PartOfSpeech.verb];

      expect(
        {
          PartOfSpeech.adjective,
          PartOfSpeech.verb,
          PartOfSpeech.noun,
        }.ordered(basedOn: basedOn),
        [PartOfSpeech.verb, PartOfSpeech.noun, PartOfSpeech.adjective],
      );
    });

    test('外して付け直しても並びは変わらない(バッジ色が変わらない)', () {
      const basedOn = [PartOfSpeech.verb, PartOfSpeech.noun];
      final selected = {PartOfSpeech.verb, PartOfSpeech.noun}
        ..remove(PartOfSpeech.verb)
        ..add(PartOfSpeech.verb);

      // Set 自体はタップ順(名詞 → 動詞)になっている。
      expect(selected.toList(), [PartOfSpeech.noun, PartOfSpeech.verb]);
      expect(selected.ordered(basedOn: basedOn), basedOn);
    });

    test('基準が空なら enum の宣言順になる', () {
      expect(
        {PartOfSpeech.adverb, PartOfSpeech.noun}.ordered(basedOn: const []),
        [PartOfSpeech.noun, PartOfSpeech.adverb],
      );
    });
  });
}
