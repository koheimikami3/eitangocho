import 'package:eitangocho/features/word_registration/domain/word_form_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('containsWordForm', () {
    test('見出し語そのものを含む文にマッチする', () {
      expect(containsWordForm('Tom obtained a gun.', 'obtain'), isTrue);
      expect(containsWordForm('He is diligent.', 'diligent'), isTrue);
    });

    test('規則変化形にマッチする', () {
      expect(containsWordForm('She obtains permission.', 'obtain'), isTrue);
      expect(containsWordForm('We are obtaining data.', 'obtain'), isTrue);
      expect(containsWordForm('He studied hard.', 'study'), isTrue);
      expect(containsWordForm('He dragged his feet.', 'drag'), isTrue);
      expect(containsWordForm('She is making dinner.', 'make'), isTrue);
    });

    // Tatoeba の検索はステミングするため、これを弾けないと無関係な文が入る。
    test('派生語しか含まない文は弾く', () {
      expect(
        containsWordForm("I'm displeased with your negligence.", 'negligible'),
        isFalse,
      );
      expect(
        containsWordForm('He was negligent of his duties.', 'negligible'),
        isFalse,
      );
      expect(
        containsWordForm('I am going to substantiate this theory.',
            'substantial'),
        isFalse,
      );
      expect(containsWordForm("It's abundantly clear.", 'abundant'), isFalse);
    });

    test('大文字・約物は無視して判定する', () {
      expect(containsWordForm('Monster!', 'monster'), isTrue);
      expect(containsWordForm('"Ghosts exist," he said.', 'ghost'), isTrue);
      expect(containsWordForm('Tom obtained a gun.', 'OBTAIN'), isTrue);
    });

    test('ハイフンで繋がった語も切り出して判定する', () {
      expect(containsWordForm('He is a well-known writer.', 'know'), isFalse);
      expect(containsWordForm('He is a well-known writer.', 'known'), isTrue);
    });

    test('アポストロフィは語中に残す', () {
      expect(containsWordForm("I don't know.", 'know'), isTrue);
    });

    test('部分一致では拾わない', () {
      expect(containsWordForm('He is a monsterous liar.', 'monster'), isFalse);
      expect(containsWordForm('The account is open.', 'count'), isFalse);
    });

    test('空文字は常に false', () {
      expect(containsWordForm('Tom obtained a gun.', '  '), isFalse);
    });
  });

  group('wordForms', () {
    test('語尾 e は落ちた形も持つ', () {
      expect(wordForms('make'), containsAll(['make', 'making', 'maked']));
    });

    test('子音 + y は ies / ied を持つ', () {
      expect(wordForms('study'), containsAll(['studies', 'studied']));
    });

    test('母音 + y は ies を作らない', () {
      expect(wordForms('play'), isNot(contains('plaies')));
      expect(wordForms('play'), containsAll(['plays', 'played']));
    });

    test('短母音 + 子音の語は子音重ねを持つ', () {
      expect(wordForms('drag'), containsAll(['dragged', 'dragging']));
      // 直前が母音 2 つ(long vowel)なら重ねない
      expect(wordForms('read'), isNot(contains('readded')));
    });
  });
}
