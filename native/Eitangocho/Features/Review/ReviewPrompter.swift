import EitangochoData
import Foundation
import OSLog

/// レビュー依頼を「いつ出すか」を決める(Flutter 版の ReviewPrompter)。
///
/// 出すのはクイズを最後まで終えた直後(`onQuizCompleted`)と、登録単語数が節目に達した
/// 保存直後(`onWordRegistered`)だけ。条件は `ReviewConfig` にまとめてある。
///
/// **レビューの失敗でアプリを止めない**(辞書・広告と同じ方針)。判定も呼び出しも失敗を握ってログだけ出す。
/// レビュー依頼は「出ない」が正常系(上限超過・ユーザーが無効化)と区別がつかず、ダイアログ自体も
/// ストア配布版でしか出ないので、判定の経路をログに残す。
final class ReviewPrompter {
  /// UserDefaults のキー。Flutter 版と同じ名前・同じ型(Int)で読み書きする。
  static let quizCompletedCountKey = "reviewQuizCompletedCount"
  /// 前回の依頼の日時(epoch ミリ秒)。
  static let lastRequestedAtKey = "reviewLastRequestedAt"

  private let client: any ReviewClient
  private let dao: WordDao
  private let analytics: AnalyticsLogger
  private let defaults: UserDefaults
  private let promptDelay: Duration
  private let now: () -> Date

  private static let logger = Logger(subsystem: "com.kohei.mikami.eitangocho", category: "review")

  /// `promptDelay` は既定値が本番の値で、テストからだけ縮める。
  init(
    client: any ReviewClient, dao: WordDao, analytics: AnalyticsLogger, defaults: UserDefaults = .standard,
    promptDelay: Duration = ReviewConfig.promptDelay, now: @escaping () -> Date = { .now }
  ) {
    self.client = client
    self.dao = dao
    self.analytics = analytics
    self.defaults = defaults
    self.promptDelay = promptDelay
    self.now = now
  }

  /// クイズを最後まで終えたときに呼ぶ。条件を満たしたときだけ依頼を出す。
  /// `okCount` は「覚えている」の数、`total` はそのセッションの出題数。
  func onQuizCompleted(okCount: Int, total: Int) async {
    // 完了回数は「達成の総量」を表す指標として使うため、成績や他の条件を満たさない回も含めて数える。
    let completions = defaults.integer(forKey: Self.quizCompletedCountKey) + 1
    defaults.set(completions, forKey: Self.quizCompletedCountKey)
    do {
      guard try await shouldRequest(okCount: okCount, total: total, completions: completions) else { return }
      await request("累計クイズ完了 \(completions) 回", trigger: .quiz)
    } catch {
      log("レビュー依頼に失敗しました: \(error)")
    }
  }

  /// 単語登録の保存直後に呼ぶ。登録単語数がちょうど節目(`ReviewConfig.wordCountMilestones`)に
  /// なったときだけ依頼を出す。
  ///
  /// 「ちょうど」で見るので、節目を一度越えた後は削除して登録し直さない限り再び当たらない
  /// (当たっても `ReviewConfig.requestInterval` が止める)。
  func onWordRegistered() async {
    do {
      let wordCount = try await dao.countWords()
      guard ReviewConfig.wordCountMilestones.contains(wordCount), !isWithinInterval() else { return }
      await request("登録単語 \(wordCount) 語", trigger: .wordMilestone)
    } catch {
      log("レビュー依頼に失敗しました: \(error)")
    }
  }

  /// `ReviewConfig` の条件をすべて満たすか。落ちた条件はログに残す。
  private func shouldRequest(okCount: Int, total: Int, completions: Int) async throws -> Bool {
    if total < ReviewConfig.minQuestions {
      log("出題数が少ないため見送ります(\(total) 語)")
      return false
    }
    if Double(okCount) / Double(total) < ReviewConfig.minKnewRatio {
      log("成績が振るわないため見送ります(\(okCount)/\(total))")
      return false
    }
    if completions < ReviewConfig.minQuizCompletions {
      log("クイズ完了が \(completions) 回目のため見送ります")
      return false
    }
    let wordCount = try await dao.countWords()
    if wordCount < ReviewConfig.minWordCount {
      log("登録単語が少ないため見送ります(\(wordCount) 語)")
      return false
    }
    return !isWithinInterval()
  }

  /// 前回の依頼から `ReviewConfig.requestInterval` が経っていないか。経っていなければログを残す。
  private func isWithinInterval() -> Bool {
    guard let millis = defaults.object(forKey: Self.lastRequestedAtKey) as? NSNumber else { return false }
    let elapsed = now().timeIntervalSince(Date(timeIntervalSince1970: millis.doubleValue / 1000))
    guard elapsed < ReviewConfig.requestInterval else { return false }
    log("前回の依頼から \(Int(elapsed / 86_400)) 日しか経っていないため見送ります")
    return true
  }

  /// 待ち時間を置いてから依頼を出し、依頼した日時を記録する。
  /// `reason` はログに出す契機の説明、`trigger` は計測に送る契機。
  private func request(_ reason: String, trigger: ReviewTrigger) async {
    // 契機の画面遷移とアニメーションが落ち着いてからシートを重ねる。
    try? await Task.sleep(for: promptDelay)

    guard client.isAvailable else {
      log("この端末ではレビュー依頼を出せません")
      return
    }
    do {
      try client.requestReview()
    } catch {
      // 記録しないので、次の契機でまた試す。
      log("レビュー依頼に失敗しました: \(error)")
      return
    }
    // **表示されたかは OS が教えてくれない**ため、呼べた時点で「依頼した」と記録する
    // (上限で出なかった回も 1 回と数える)。表示の確認まで待つ手段は無い。
    defaults.set(Int(now().timeIntervalSince1970 * 1000), forKey: Self.lastRequestedAtKey)
    analytics.logReviewRequested(trigger)
    log("レビュー依頼を出しました(\(reason))")
  }

  private func log(_ message: String) {
    Self.logger.debug("\(message, privacy: .public)")
  }
}
