#if os(iOS)
  import GoogleMobileAds
  import SwiftUI
  import UIKit

  /// クイズを解き終えて、結果の画面に移る前に出すインタースティシャル(2026-11-01 のユーザーの判断)。
  ///
  /// 出題中に読み込んでおき、最後の問題に答えたら結果の画面を出さずに待たせ(`isHoldingResult`)、
  /// 少し置いてから出す。閉じたら結果の画面を出す。結果の画面のレクタングルは、インタースティシャルの
  /// 裏で表示を数えないよう、閉じてから出る(待たせている間は結果の画面そのものを作らない)。
  ///
  /// 頻度は AdMob の管理画面の上限(1 時間に 1 回)で絞り、アプリ側では回数を数えない。上限に当たっている
  /// 間は読み込みが在庫なしで返るので、その回は出さずにすぐ結果へ進む。出した回はレビュー依頼を見送る
  /// (`ReviewPrompter` が `isHoldingResult` を見る)。
  @Observable
  final class QuizInterstitialAd: NSObject, FullScreenContentDelegate {
    /// 結果の画面を出さずに待たせている間(インタースティシャルを出す直前から閉じるまで)。
    private(set) var isHoldingResult = false

    @ObservationIgnored private var ad: InterstitialAd?
    @ObservationIgnored private var loadedAt: Date?
    @ObservationIgnored private var loading = false

    /// 最後の回答から出すまでの間。押した指がそのまま広告に触れないように置く。
    private static let presentDelay: Duration = .milliseconds(500)
    /// 読み込んだ広告を使う期限(Google は読み込みから 1 時間で期限切れとしている)。
    private static let maxAge: TimeInterval = 60 * 60

    private var hasFreshAd: Bool {
      guard ad != nil, let loadedAt else { return false }
      return Date.now.timeIntervalSince(loadedAt) < Self.maxAge
    }

    /// 次に解き終えたときのために読み込んでおく(読み込み済み・読み込み中なら何もしない)。
    func prepare(ads: AdsController, purchase: PurchaseModel) {
      guard !AdUnitIds.quizInterstitial.isEmpty, !purchase.proUnlocked, !loading, !hasFreshAd else { return }
      loading = true
      Task { [weak self] in
        defer { self?.loading = false }
        guard await ads.isEnabled(), !purchase.proUnlocked else { return }
        do {
          let ad = try await InterstitialAd.load(with: AdUnitIds.quizInterstitial, request: Request())
          ad.fullScreenContentDelegate = self
          self?.ad = ad
          self?.loadedAt = .now
          adLogger.info("インタースティシャルの読み込み成功")
        } catch {
          // 頻度の上限に当たっている間もここに来る(在庫なし)。次の回の出題中に読み込み直す。
          adLogger.info("インタースティシャルの読み込み失敗: \(error.localizedDescription, privacy: .public)")
        }
      }
    }

    /// 最後の問題に答える直前に呼ぶ。出せる広告があれば結果の画面を待たせ、true を返す
    /// (呼び出し側は回答を終えたら `present(roundFinished:)` を呼ぶ)。すでに待たせているときは false。
    func holdResultIfReady(purchase: PurchaseModel) -> Bool {
      guard !isHoldingResult, hasFreshAd, !purchase.proUnlocked else { return false }
      isHoldingResult = true
      return true
    }

    /// 回答を終えた後に呼ぶ。回が終わっていれば少し置いてから出し、終わっていなければ
    /// (書き込みの失敗など)待たせるのをやめる。
    func present(roundFinished: Bool) async {
      guard roundFinished, let ad else {
        release()
        return
      }
      try? await Task.sleep(for: Self.presentDelay)
      guard let viewController = Self.topViewController() else {
        release()
        return
      }
      self.ad = nil
      ad.present(from: viewController)
    }

    func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
      release()
    }

    func ad(_ ad: any FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
      adLogger.info("インタースティシャルを出せませんでした: \(error.localizedDescription, privacy: .public)")
      release()
    }

    private func release() {
      isHoldingResult = false
    }

    /// 広告を出す画面(いちばん上に出ている画面)。
    private static func topViewController() -> UIViewController? {
      let root = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap(\.windows)
        .first(where: \.isKeyWindow)?
        .rootViewController
      var top = root
      while let presented = top?.presentedViewController { top = presented }
      return top
    }
  }

  extension EnvironmentValues {
    /// クイズの後のインタースティシャル。RootView が配る。
    @Entry var quizInterstitial: QuizInterstitialAd?
  }
#endif
