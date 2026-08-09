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

  // 句動詞。Tatoeba・kaikki とも実際に返してくる文で確認する。
  group('containsWordForm(句)', () {
    test('先頭語の規則変化を許して句を含む文にマッチする', () {
      expect(containsWordForm('I give up!', 'give up'), isTrue);
      expect(containsWordForm('I look forward to that.', 'look forward to'),
          isTrue);
      expect(
        containsWordForm('Are you looking forward to spring?', 'look forward to'),
        isTrue,
      );
      expect(containsWordForm('Stop putting off finding a job.', 'put off'),
          isTrue);
    });

    test('語順が変わっても・目的語が割り込んでもマッチする', () {
      // 受動態で put と off が離れる
      expect(containsWordForm('The wedding was put off.', 'put off'), isTrue);
      // give と up の間に目的語が挟まる
      expect(containsWordForm('They give it up easily.', 'give up'), isTrue);
    });

    test('後続の語を欠く文は弾く', () {
      expect(containsWordForm('I gave him a book.', 'give up'), isFalse);
      expect(containsWordForm('I look at the sky.', 'look forward to'), isFalse);
    });

    test('先頭語の不規則変化は拾えない(既知の制約)', () {
      expect(containsWordForm('He gave up smoking.', 'give up'), isFalse);
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
