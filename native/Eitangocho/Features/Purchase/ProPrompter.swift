import EitangochoData
import Foundation
import OSLog

/// 登録単語数が一定を超えた人に、単語登録の保存直後に Pro の案内を 1 回だけ出すかを決める(iOS だけ)。
///
/// 条件は `ProPromptConfig` にまとめてある。参照モデルはレビュー依頼の `ReviewPrompter`
/// (保存直後に呼ぶ・待ってから出す・失敗でアプリを止めない)。
///
/// **案内の失敗でアプリを止めない**(広告・課金・レビューと同じ方針)。判定の失敗は握ってログだけ出す。
@MainActor
final class ProPrompter {
  /// UserDefaults のキー。最後に出した案内の番号(`ProPromptConfig.campaign`)を Int で持つ。
  static let shownCampaignKey = "proPromptShownCampaign"

  private let dao: WordDao
  private let analytics: AnalyticsLogger
  private let defaults: UserDefaults
  private let promptDelay: Duration
  private let canOffer: () -> Bool

  private static let logger = Logger(subsystem: "com.kohei.mikami.eitangocho", category: "proPrompt")

  /// `canOffer` は購入の側の条件(購入状態が分かっていて未購入、かつ価格が取れている)。
  /// 押せない購入ボタンの案内で 1 回きりを使い切らないよう、価格まで見る。
  /// `promptDelay` は既定値が本番の値で、テストからだけ縮める。
  init(
    dao: WordDao, analytics: AnalyticsLogger, defaults: UserDefaults = .standard,
    promptDelay: Duration = ProPromptConfig.promptDelay, canOffer: @escaping () -> Bool
  ) {
    self.dao = dao
    self.analytics = analytics
    self.defaults = defaults
    self.promptDelay = promptDelay
    self.canOffer = canOffer
  }

  /// 単語登録シートから保存してシートを閉じた直後に呼ぶ。条件を満たせば待ってから `present` を呼ぶ。
  ///
  /// `present` は案内を出せたかを返す。ほかのシート・ダイアログが出ていて出せなかったときは記録せず、
  /// 次の登録の後にまた試す。
  func onWordRegistered(present: () -> Bool) async {
    guard await shouldPrompt() else { return }
    // シートが閉じる動きが落ち着いてから重ねる。
    try? await Task.sleep(for: promptDelay)
    // 待っている間に購入された・ほかの画面が出た場合に備えて、出す直前にもう一度見る。
    guard canOffer(), present() else {
      log("ほかの表示が出ているため見送ります")
      return
    }
    defaults.set(ProPromptConfig.campaign, forKey: Self.shownCampaignKey)
    analytics.logProPromptShown()
    log("Pro の案内を出しました(番号 \(ProPromptConfig.campaign))")
  }

  /// 案内を出す条件をすべて満たすか。落ちた条件はログに残す。
  private func shouldPrompt() async -> Bool {
    if defaults.integer(forKey: Self.shownCampaignKey) >= ProPromptConfig.campaign {
      return false
    }
    if !canOffer() {
      log("購入済み・購入状態が未確定・価格が取れていないため見送ります")
      return false
    }
    do {
      let wordCount = try await dao.countWords()
      if wordCount < ProPromptConfig.minWordCount {
        return false
      }
      // 節目の保存ではレビュー依頼が出うる。続けて 2 つ出さないよう、この回は譲って次の登録に回す。
      if ReviewConfig.wordCountMilestones.contains(wordCount) {
        log("レビュー依頼の節目(\(wordCount) 語)のため見送ります")
        return false
      }
      return true
    } catch {
      log("Pro の案内の判定に失敗しました: \(error)")
      return false
    }
  }

  private func log(_ message: String) {
    Self.logger.debug("\(message, privacy: .public)")
  }
}
