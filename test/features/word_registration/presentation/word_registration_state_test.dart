import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/word_registration/domain/registration_error.dart';
import 'package:eitangocho/features/word_registration/domain/word_info.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const full = WordInfo(
    word: 'serendipity',
    ipa: '/ˌsɛ.ɹən.ˈdɪ.pɪ.ti/',
    partsOfSpeech: [PartOfSpeech.noun],
    meaning: '思わぬ発見',
    exampleEn: 'A lucky find.',
    exampleTranslation: '幸運な発見。',
    audioUrl: '',
  );

  group('notice', () {
    test('全部埋まっていれば出さない', () {
      expect(const WordRegistrationState(fetched: full).notice, isNull);
    });

    test('未収録なら手動入力を促す', () {
      expect(
        const WordRegistrationState(notFound: true).notice,
        RegistrationNotice.notFound,
      );
    });

    // EJDict は句動詞を 1 件も収録していないため、句動詞ではこれが常態になる。
    test('訳が空なら、他が埋まっていても訳の不足を先に伝える', () {
      final state = WordRegistrationState(fetched: full.copyWith(meaning: ''));

      expect(state.notice, RegistrationNotice.meaningNotFound);
    });

    test('訳だけ取れたときは IPA と例文の不足を伝える', () {
      final state = WordRegistrationState(
        fetched: full.copyWith(ipa: '', exampleEn: ''),
      );

      expect(state.notice, RegistrationNotice.onlyMeaningFound);
    });

    test('手動入力へスキップしたときは出さない', () {
      expect(const WordRegistrationState().notice, isNull);
    });
  });
}
