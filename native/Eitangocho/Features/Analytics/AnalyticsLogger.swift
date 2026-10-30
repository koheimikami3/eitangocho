import EitangochoData
import EitangochoSync
import Foundation

/// 独自イベントの送信口(Flutter 版の AnalyticsLogger)。イベント名とパラメータの組み立てをここに集約し、
/// 呼び出し側は 1 行で済むようにする。
///
/// 各イベントは「値によってどの判断が変わるか」で絞り込んだもの(docs/design.md「計測」)。
/// **ユーザーが入力した中身(単語・訳・検索語・例文)は送らない**。送るのは区分と件数だけ。
/// 名前と値は Flutter 版と同じ(変えると過去のデータとつながらない)。
struct AnalyticsLogger {
  /// soon_after_quiz の判定に使う、クイズで答えてからの時間。
  static let soonAfterQuiz: TimeInterval = 24 * 60 * 60

  private let client: any AnalyticsClient

  init(_ client: any AnalyticsClient) {
    self.client = client
  }

  private func log(_ name: String, _ parameters: [String: AnyHashable] = [:]) {
    client.logEvent(name, parameters: parameters)
  }

  func logScreenView(_ screen: String) {
    client.logScreenView(screen)
  }

  /// ユーザープロパティ。送り分けは AnalyticsReporter が決める。
  func setUserProperty(_ name: String, value: String?) {
    client.setUserProperty(name, value: value)
  }

  /// 自動入力の結果。`notice` は取得できたとき(success)だけ意味を持つ。
  func logAutofillResult(_ result: AutofillResult, isPhrase: Bool, notice: WordRegistrationModel.Notice? = nil) {
    var parameters: [String: AnyHashable] = [
      "result": snakeCase(result.rawValue),
      "is_phrase": boolValue(isPhrase),
    ]
    if result == .success {
      parameters["notice"] = notice.map { snakeCase(String(describing: $0)) } ?? "none"
    }
    log("autofill_result", parameters)
  }

  /// 単語の登録。自動入力の値を書き換えたかは自動入力のときだけ送る(手動入力では比べる元が無い)。
  func logWordRegistered(
    autoFilled: Bool, editedMeaning: Bool = false, editedExample: Bool = false, editedIpa: Bool = false
  ) {
    var parameters: [String: AnyHashable] = ["method": autoFilled ? "autofill" : "manual"]
    if autoFilled {
      parameters["edited_meaning"] = boolValue(editedMeaning)
      parameters["edited_example"] = boolValue(editedExample)
      parameters["edited_ipa"] = boolValue(editedIpa)
    }
    log("word_registered", parameters)
  }

  /// 「覚えた」の付け外し(ユーザーの操作だけ。クイズの「忘れていた」による自動の戻しは送らない)。
  ///
  /// soon_after_quiz は、クイズで答えてから `soonAfterQuiz` 以内の操作か。「忘れていた」で学習中に
  /// 戻された単語をすぐ付け直しているかを見て、自動で戻す仕様の要否を判断するためのもの。
  func logWordLearnedToggled(_ word: Word, isLearned: Bool, now: Date = .now) {
    let soon = word.lastReviewedAt.map { now.timeIntervalSince($0) < Self.soonAfterQuiz } ?? false
    log("word_learned_toggled", ["to": isLearned ? "learned" : "learning", "soon_after_quiz": boolValue(soon)])
  }

  func logWordDeleted(_ word: Word) {
    log("word_deleted", ["was_learned": boolValue(word.isLearned)])
  }

  func logPronunciationOpened(_ view: MainView) {
    log("pronunciation_opened", ["screen": screenName(view)])
  }

  func logSearchUsed(_ view: MainView) {
    log("search_used", ["screen": screenName(view)])
  }

  func logQuizStarted(trigger: QuizTrigger, questions: [Word], now: Date = .now) {
    log(
      "quiz_started",
      [
        "trigger": quizTriggerValue(trigger),
        "review_gap_bucket": reviewGapBucket(questions.map(\.lastReviewedAt), now: now),
      ])
  }

  func logQuizEmptyShown() {
    log("quiz_empty_shown")
  }

  func logQuizCompleted(okCount: Int, forgotCount: Int) {
    log("quiz_completed", ["ok_count": okCount, "forgot_count": forgotCount])
  }

  func logQuizAbandoned(answeredCount: Int) {
    log("quiz_abandoned", ["answered_count": answeredCount])
  }

  /// 同期の失敗。OS が返す説明(SyncFailure.detail)はパスが混ざりうるので送らない。
  func logSyncFailed(_ reason: CloudFailureReason) {
    log("sync_failed", ["reason": syncFailureValue(reason)])
  }

  func logDataExported() {
    log("data_exported")
  }

  func logDataImported(succeeded: Bool) {
    log("data_imported", ["result": succeeded ? "success" : "failed"])
  }

  /// 作者の他のアプリ(iOS の設定画面だけ。Phase 6 で呼ぶ)。`app` は Flutter 版の AuthorApp の名前。
  func logAuthorAppTapped(_ app: String) {
    log("author_app_tapped", ["app": app])
  }

  func logStoreListingOpened() {
    log("store_listing_opened")
  }

  /// Pro の購入(iOS だけ。Phase 6 で呼ぶ)。
  func logProPurchase(_ stage: ProPurchaseStage) {
    log("pro_purchase", ["stage": stage.rawValue])
  }

  /// クイズ結果の広告の下にある Pro への導線を押した(iOS だけ。Phase 6 で呼ぶ)。導線を残すか外すかの
  /// 判断に使う(pro_purchase と並べて、導線経由で購入まで進む人がいるかを見る)。
  func logProLinkTapped() {
    log("pro_link_tapped")
  }

  /// OS のレビュー依頼を呼んだ。実際に表示されたかは OS が教えてくれないため、
  /// 「依頼を試みた回数」の目安として見る(契機ごとの条件が厳しすぎないかの判断用)。
  func logReviewRequested(_ trigger: ReviewTrigger) {
    log("review_requested", ["trigger": snakeCase(trigger.rawValue)])
  }
}
