import EitangochoSync
import Foundation

// 計測に送る値の変換(Flutter 版の analytics_values.dart)。GA4 のレポートで読みやすく、後から
// 変えないで済む文字列にそろえる。**名前と値は Flutter 版と同じにする**(変えると過去のデータとつながらない)。

/// 単語の自動入力の結果(autofill_result の result)。
enum AutofillResult: String, Sendable {
  case success, notFound, fetchFailed
}

/// クイズを始めた契機(quiz_started の trigger)。
enum QuizTrigger: Sendable {
  /// サイドバー・タブバーからクイズを開いた。
  case tab
  /// 結果画面の「続ける」。
  case continued
}

/// Pro 購入の段階(pro_purchase の stage)。
enum ProPurchaseStage: String, Sendable {
  case tapped, success, cancelled, failed
}

/// レビュー依頼を出した契機(review_requested の trigger)。
enum ReviewTrigger: String, Sendable {
  /// クイズを最後まで終えた直後。
  case quiz
  /// 登録単語数が節目(50 / 100 語)に達した直後。
  case wordMilestone
}

/// enum の名前(lowerCamelCase)を snake_case にする。
func snakeCase(_ camel: String) -> String {
  camel.reduce(into: "") { result, character in
    if character.isUppercase {
      result += "_" + character.lowercased()
    } else {
      result.append(character)
    }
  }
}

/// 画面名(screen_view の screen_name、各イベントの screen)。
func screenName(_ view: MainView) -> String {
  snakeCase(String(describing: view))
}

/// `QuizTrigger` の値。Flutter 版では `continue` が予約語のため enum の名前とずらしてあり、値はそちらに合わせる。
func quizTriggerValue(_ trigger: QuizTrigger) -> String {
  switch trigger {
  case .tab: "tab"
  case .continued: "continue"
  }
}

/// 出題方向。enum の名前の `ja` は多言語化前の名残で、訳の言語は日本語に限らないため、
/// 英語から / 英語への向きで表す。
func quizDirectionValue(_ direction: QuizDirection) -> String {
  switch direction {
  case .enToJa: "from_english"
  case .jaToEn: "to_english"
  }
}

/// 同期の失敗理由。`noICloud` を機械的に snake_case にすると `no_i_cloud` になるため、個別に書く。
func syncFailureValue(_ reason: CloudFailureReason) -> String {
  switch reason {
  case .noICloud: "no_icloud"
  case .notCurrent: "not_current"
  case .unsupportedPlatform: "unsupported_platform"
  case .failed: "failed"
  }
}

/// 登録単語数の区間(word_count_bucket)。
///
/// 値の頭の番号は、GA4 が値を文字列の辞書順に並べるため(番号が無いと
/// 「1-9」「10-49」「100-299」「2000+」「50-99」の順になる)。
func wordCountBucket(_ count: Int) -> String {
  switch count {
  case ...0: "0_none"
  case ..<10: "1_1-9"
  case ..<50: "2_10-49"
  case ..<100: "3_50-99"
  case ..<300: "4_100-299"
  case ..<500: "5_300-499"
  case ..<1000: "6_500-999"
  case ..<2000: "7_1000-1999"
  default: "8_2000+"
  }
}

/// クイズの出題のうち、前回答えてから最も日が空いていた単語の日数の区間
/// (quiz_started の review_gap_bucket)。
///
/// 出題の選び方(selectQuizQuestions)が学習済みの単語を等間隔で一巡させられているかを見るためのもの。
/// まだ一度も答えていない単語は日数が無いので除き、全部がそうなら `0_none`。
/// 日数は Dart の `Duration.inDays` と同じく 24 時間単位の切り捨て。
func reviewGapBucket(_ lastReviewedAts: [Date?], now: Date) -> String {
  let gaps = lastReviewedAts.compactMap { $0 }.map { Int(now.timeIntervalSince($0) / 86_400) }
  guard let days = gaps.max() else { return "0_none" }
  switch days {
  case ..<7: return "1_0-6"
  case ..<30: return "2_7-29"
  case ..<90: return "3_30-89"
  default: return "4_90+"
  }
}

/// GA4 のパラメータとユーザープロパティは bool を受けないため文字列にする。
func boolValue(_ value: Bool) -> String {
  value ? "true" : "false"
}
