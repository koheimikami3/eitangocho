import Foundation
import Testing

@testable import Eitangocho

/// Flutter 版の test/features/analytics/domain/analytics_values_test.dart を移したもの。
struct AnalyticsValuesTests {
  @Test func wordCountBucketは区間の境界で切り替わる() {
    #expect(wordCountBucket(0) == "0_none")
    #expect(wordCountBucket(1) == "1_1-9")
    #expect(wordCountBucket(9) == "1_1-9")
    #expect(wordCountBucket(10) == "2_10-49")
    #expect(wordCountBucket(49) == "2_10-49")
    #expect(wordCountBucket(50) == "3_50-99")
    #expect(wordCountBucket(100) == "4_100-299")
    #expect(wordCountBucket(300) == "5_300-499")
    #expect(wordCountBucket(500) == "6_500-999")
    #expect(wordCountBucket(999) == "6_500-999")
    #expect(wordCountBucket(1000) == "7_1000-1999")
    #expect(wordCountBucket(2000) == "8_2000+")
  }

  // MARK: - reviewGapBucket

  private let now = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 10, day: 15, hour: 12))!

  private func daysAgo(_ days: Int) -> Date {
    now.addingTimeInterval(-Double(days) * 86_400)
  }

  @Test func まだ一度も答えていない単語だけなら0_none() {
    #expect(reviewGapBucket([nil, nil], now: now) == "0_none")
    #expect(reviewGapBucket([], now: now) == "0_none")
  }

  @Test func 最も日が空いた単語の日数で決まり未回答の単語は除く() {
    #expect(reviewGapBucket([nil, daysAgo(2), daysAgo(40)], now: now) == "3_30-89")
  }

  @Test func reviewGapBucketは区間の境界で切り替わる() {
    func gap(_ days: Int) -> String { reviewGapBucket([daysAgo(days)], now: now) }
    #expect(gap(0) == "1_0-6")
    #expect(gap(6) == "1_0-6")
    #expect(gap(7) == "2_7-29")
    #expect(gap(29) == "2_7-29")
    #expect(gap(30) == "3_30-89")
    #expect(gap(90) == "4_90+")
  }

  @Test func enumの名前と画面名はsnake_caseにする() {
    #expect(snakeCase(WordSortOrder.reverseAlphabetical.rawValue) == "reverse_alphabetical")
    #expect(snakeCase(LearningCardLayout.twoColumns.rawValue) == "two_columns")
    #expect(screenName(.allWords) == "all_words")
    #expect(screenName(.learning) == "learning")
  }

  @Test func 機械的に変換すると崩れる値は個別に決める() {
    #expect(syncFailureValue(.noICloud) == "no_icloud")
    #expect(quizTriggerValue(.continued) == "continue")
  }
}
