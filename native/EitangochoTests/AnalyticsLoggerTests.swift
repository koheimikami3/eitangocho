import EitangochoData
import Foundation
import Testing

@testable import Eitangocho

/// Flutter 版の test/features/analytics/data/analytics_logger_test.dart を移したもの。
@MainActor
struct AnalyticsLoggerTests {
  private let client = FakeAnalyticsClient()
  private var logger: AnalyticsLogger { AnalyticsLogger(client) }

  private static func word(isLearned: Bool = false, lastReviewedAt: Date? = nil) -> Word {
    let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026))!
    return Word(
      id: 1, word: "apple", meaning: "りんご", isLearned: isLearned, lastReviewedAt: lastReviewedAt, createdAt: date,
      updatedAt: date)
  }

  // MARK: - autofill_result

  @Test func 取得できたときだけnoticeを送り警告が無ければnone() {
    logger.logAutofillResult(.success, isPhrase: false)
    logger.logAutofillResult(.success, isPhrase: true, notice: .meaningNotFound)
    logger.logAutofillResult(.notFound, isPhrase: false)

    #expect(
      client.eventsNamed("autofill_result") == [
        ["result": "success", "notice": "none", "is_phrase": "false"],
        ["result": "success", "notice": "meaning_not_found", "is_phrase": "true"],
        ["result": "not_found", "is_phrase": "false"],
      ])
  }

  // MARK: - word_registered

  @Test func 自動入力なら書き換えの有無を送る() {
    logger.logWordRegistered(autoFilled: true, editedMeaning: true)
    #expect(
      client.eventsNamed("word_registered") == [
        ["method": "autofill", "edited_meaning": "true", "edited_example": "false", "edited_ipa": "false"]
      ])
  }

  @Test func 手動入力では比べる元が無いので書き換えの有無を送らない() {
    logger.logWordRegistered(autoFilled: false)
    #expect(client.eventsNamed("word_registered") == [["method": "manual"]])
  }

  // MARK: - word_learned_toggled

  private let now = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 10, day: 15, hour: 12))!

  @Test func クイズで答えてから24時間以内ならsoon_after_quiz() {
    logger.logWordLearnedToggled(
      Self.word(lastReviewedAt: now.addingTimeInterval(-23 * 3600)), isLearned: true, now: now)
    #expect(client.eventsNamed("word_learned_toggled") == [["to": "learned", "soon_after_quiz": "true"]])
  }

  @Test func 二十四時間を過ぎているか一度も答えていなければfalse() {
    logger.logWordLearnedToggled(
      Self.word(lastReviewedAt: now.addingTimeInterval(-24 * 3600)), isLearned: true, now: now)
    logger.logWordLearnedToggled(Self.word(), isLearned: false, now: now)
    #expect(
      client.eventsNamed("word_learned_toggled") == [
        ["to": "learned", "soon_after_quiz": "false"],
        ["to": "learning", "soon_after_quiz": "false"],
      ])
  }
}
