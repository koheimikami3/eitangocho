import StoreKit
import SwiftUI

/// レビュー依頼の呼び出しを閉じ込める抽象(Flutter 版の ReviewClient)。テストではフェイクに差し替える。
protocol ReviewClient {
  /// レビュー依頼を出せる状態か。false なら `requestReview()` は呼ばない。
  var isAvailable: Bool { get }

  /// OS 標準のレビュー依頼を出す。
  ///
  /// **実際に表示されたかは OS が教えてくれない**(上限を超えた・ユーザーが設定で無効にした場合は黙って何も起きない)。
  /// 呼べたかどうかまでしか分からない前提で扱うこと。
  func requestReview() throws
}

/// StoreKit による実装。`@Environment(\.requestReview)` は画面からしか取れないので、
/// アプリのルート(RootView)が画面を出したときに `action` を渡す。渡す前は出せない状態として扱う。
final class StoreReviewClient: ReviewClient {
  var action: RequestReviewAction?

  var isAvailable: Bool { action != nil }

  func requestReview() {
    action?()
  }
}
