import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/analytics/data/analytics_logger.dart';
import 'package:eitangocho/features/analytics/domain/analytics_values.dart';
import 'package:eitangocho/features/word_registration/domain/registration_error.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fake_analytics_client.dart';

Word _word({bool isLearned = false, DateTime? lastReviewedAt}) => Word(
  id: 1,
  word: 'apple',
  ipa: '',
  meaning: 'りんご',
  partsOfSpeech: const <PartOfSpeech>[],
  exampleEn: '',
  exampleTranslation: '',
  translationLanguage: 'ja',
  audioUrl: '',
  isLearned: isLearned,
  lastReviewedAt: lastReviewedAt,
  correctCount: 0,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  late FakeAnalyticsClient client;
  late AnalyticsLogger logger;

  setUp(() {
    client = FakeAnalyticsClient();
    logger = AnalyticsLogger(client);
  });

  group('autofill_result', () {
    test('取得できたときだけ notice を送り、警告が無ければ none', () {
      logger
        ..logAutofillResult(result: AutofillResult.success, isPhrase: false)
        ..logAutofillResult(
          result: AutofillResult.success,
          isPhrase: true,
          notice: RegistrationNotice.meaningNotFound,
        )
        ..logAutofillResult(result: AutofillResult.notFound, isPhrase: false);

      expect(client.eventsNamed('autofill_result'), [
        {'result': 'success', 'notice': 'none', 'is_phrase': 'false'},
        {
          'result': 'success',
          'notice': 'meaning_not_found',
          'is_phrase': 'true',
        },
        {'result': 'not_found', 'is_phrase': 'false'},
      ]);
    });
  });

  group('word_registered', () {
    test('自動入力なら書き換えの有無を送る', () {
      logger.logWordRegistered(autoFilled: true, editedMeaning: true);

      expect(client.eventsNamed('word_registered').single, {
        'method': 'autofill',
        'edited_meaning': 'true',
        'edited_example': 'false',
        'edited_ipa': 'false',
      });
    });

    test('手動入力では比べる元が無いので書き換えの有無を送らない', () {
      logger.logWordRegistered(autoFilled: false);

      expect(client.eventsNamed('word_registered').single, {
        'method': 'manual',
      });
    });
  });

  group('word_learned_toggled', () {
    final now = DateTime(2026, 10, 15, 12);

    test('クイズで答えてから 24 時間以内なら soon_after_quiz', () {
      logger.logWordLearnedToggled(
        _word(lastReviewedAt: now.subtract(const Duration(hours: 23))),
        isLearned: true,
        now: now,
      );

      expect(client.eventsNamed('word_learned_toggled').single, {
        'to': 'learned',
        'soon_after_quiz': 'true',
      });
    });

    test('24 時間を過ぎているか、一度も答えていなければ false', () {
      logger
        ..logWordLearnedToggled(
          _word(lastReviewedAt: now.subtract(const Duration(hours: 24))),
          isLearned: true,
          now: now,
        )
        ..logWordLearnedToggled(_word(), isLearned: false, now: now);

      expect(client.eventsNamed('word_learned_toggled'), [
        {'to': 'learned', 'soon_after_quiz': 'false'},
        {'to': 'learning', 'soon_after_quiz': 'false'},
      ]);
    });
  });
}
