import EitangochoData
import Foundation

@testable import Eitangocho

/// 呼ばれた回数を数えるだけの ReviewClient(Flutter 版の FakeReviewClient)。
final class FakeReviewClient: ReviewClient {
  var isAvailable = true
  /// 設定すると requestReview がこれを投げる(SDK の失敗の代わり)。
  var requestError: (any Error)?
  private(set) var requestCount = 0

  func requestReview() throws {
    requestCount += 1
    if let requestError { throw requestError }
  }
}

/// レビュー依頼を出さない ReviewPrompter(Flutter 版の reviewDisabled)。
///
/// クイズを最後まで進める・単語を登録するテストは完了時にレビュー依頼の判定を通るため、
/// レビューそのものを検証するテスト以外はこれを渡す。完了回数は使い捨ての UserDefaults に書く。
func disabledReviewPrompter(dao: WordDao) -> ReviewPrompter {
  let client = FakeReviewClient()
  client.isAvailable = false
  return ReviewPrompter(
    client: client, dao: dao, analytics: AnalyticsLogger(NoopAnalyticsClient()),
    defaults: UserDefaults(suiteName: "disabledReviewPrompter-\(UUID().uuidString)")!, promptDelay: .zero)
}
