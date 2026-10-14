import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/features/analytics/domain/analytics_values.dart';
import 'package:eitangocho/features/settings/domain/learning_card_layout.dart';
import 'package:eitangocho/features/settings/domain/word_sort_order.dart';
import 'package:eitangocho/features/sync/domain/cloud_file_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wordCountBucket は区間の境界で切り替わる', () {
    expect(wordCountBucket(0), '0_none');
    expect(wordCountBucket(1), '1_1-9');
    expect(wordCountBucket(9), '1_1-9');
    expect(wordCountBucket(10), '2_10-49');
    expect(wordCountBucket(49), '2_10-49');
    expect(wordCountBucket(50), '3_50-99');
    expect(wordCountBucket(100), '4_100-299');
    expect(wordCountBucket(300), '5_300-499');
    expect(wordCountBucket(500), '6_500-999');
    expect(wordCountBucket(999), '6_500-999');
    expect(wordCountBucket(1000), '7_1000-1999');
    expect(wordCountBucket(2000), '8_2000+');
  });

  group('reviewGapBucket', () {
    final now = DateTime(2026, 10, 15, 12);

    test('まだ一度も答えていない単語だけなら 0_none', () {
      expect(reviewGapBucket([null, null], now), '0_none');
      expect(reviewGapBucket(const [], now), '0_none');
    });

    test('最も日が空いた単語の日数で決まり、未回答の単語は除く', () {
      expect(
        reviewGapBucket([
          null,
          now.subtract(const Duration(days: 2)),
          now.subtract(const Duration(days: 40)),
        ], now),
        '3_30-89',
      );
    });

    test('区間の境界で切り替わる', () {
      String gap(int days) =>
          reviewGapBucket([now.subtract(Duration(days: days))], now);
      expect(gap(0), '1_0-6');
      expect(gap(6), '1_0-6');
      expect(gap(7), '2_7-29');
      expect(gap(29), '2_7-29');
      expect(gap(30), '3_30-89');
      expect(gap(90), '4_90+');
    });
  });

  test('enum 名と画面名は snake_case にする', () {
    expect(
      snakeCase(WordSortOrder.reverseAlphabetical.name),
      'reverse_alphabetical',
    );
    expect(snakeCase(LearningCardLayout.twoColumns.name), 'two_columns');
    expect(screenName(MainView.allWords), 'all_words');
    expect(screenName(MainView.learning), 'learning');
  });

  test('機械的に変換すると崩れる値は個別に決める', () {
    expect(syncFailureValue(CloudFailureReason.noICloud), 'no_icloud');
    expect(quizTriggerValue(QuizTrigger.continued), 'continue');
  });
}
