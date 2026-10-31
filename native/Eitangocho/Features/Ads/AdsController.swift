import Foundation

#if os(iOS)
  import GoogleMobileAds
#endif

/// 広告 SDK の初期化を閉じ込める抽象。テストではフェイクに差し替える
/// (テストは macOS で動き、macOS には広告の SDK をリンクしていないため)。
protocol AdsSDK {
  func start() async
}

/// 広告の無い OS(macOS)の実装。呼ばれない。
struct NoAdsSDK: AdsSDK {
  func start() async {}
}

#if os(iOS)
  /// Google Mobile Ads による実装。
  struct GoogleMobileAdsSDK: AdsSDK {
    func start() async {
      let status = await MobileAds.shared.start()
      adLogger.info("SDK 初期化完了: \(status.adapterStatusesByClassName.keys.joined(separator: ", "), privacy: .public)")
    }
  }
#endif

/// 広告を表示してよいかを決める(Flutter 版の adsEnabledProvider)。true を返した時点で広告 SDK は初期化済み。
///
/// 広告の出し分けはこの真偽値 1 点に集約する。一度決めた値は起動中ずっと保つ(Flutter 版の keepAlive と同じ。
/// 枠が作り直されるたびに SDK の初期化と ATT の確認をやり直さないため)。
///
/// 購入状態の変化は見張らない(Flutter 版は watch すると確定待ちの最中に自分自身が無効化され、
/// 待っている呼び出し側が取り残された)。購入が後から成立したときに広告を止める役目は `MobileAdSlot` が持つ。
final class AdsController {
  private let purchase: PurchaseModel
  private let tracking: TrackingAuthorizer
  private let sdk: any AdsSDK
  /// 広告を出す OS か(iOS だけ)。テストは macOS で動くので、テストからだけ true にする。
  private let platformSupported: Bool
  private let hasAnyUnit: Bool
  /// 購入状態の確定を待つ上限。
  private let purchaseStateTimeout: Duration

  private var decision: Task<Bool, Never>?

  init(
    purchase: PurchaseModel, tracking: TrackingAuthorizer, sdk: any AdsSDK, platformSupported: Bool,
    hasAnyUnit: Bool = AdUnitIds.hasAnyUnit, purchaseStateTimeout: Duration = .seconds(3)
  ) {
    self.purchase = purchase
    self.tracking = tracking
    self.sdk = sdk
    self.platformSupported = platformSupported
    self.hasAnyUnit = hasAnyUnit
    self.purchaseStateTimeout = purchaseStateTimeout
  }

  /// 広告を表示してよいか。初めて呼ばれたときに決め、以後は同じ値を返す。
  func isEnabled() async -> Bool {
    if let decision { return await decision.value }
    let task = Task { await decide() }
    decision = task
    return await task.value
  }

  private func decide() async -> Bool {
    // 広告は iOS のみ。
    guard platformSupported else { return false }
    // 広告ユニットが 1 つも配線されていない間は SDK に触れない。GMA SDK は不正なアプリ ID で
    // 初期化すると例外を投げるため、初期化ごと見送る。
    //
    // 購入状態の確認より前に置くのは、出す広告が 1 つも無いときに RevenueCat の応答を待たずに済ませるため。
    guard hasAnyUnit else {
      adLogger.info("広告ユニット ID が空のため広告を出しません")
      return false
    }

    // RevenueCat の応答を待ってから先へ進む。理由は 2 つ。
    //
    // ひとつは `PurchaseModel.proUnlocked` の初期値が false で、待たずに読むと Pro 購入者にも
    // トラッキング許可を求めてしまうこと。もうひとつは、課金と ATT の 2 つの SDK が同時にダイアログを
    // 出す状況を作らないこと(後から出そうとした方は黙って出ないまま返る)。
    //
    // 圏外の初回起動では entitlement が取れず永久に待つことになるため上限を置き、超えたら未購入として
    // 進む(広告が出るだけで実害はない)。
    if !(await purchase.proUnlockedKnown.wait(timeout: purchaseStateTimeout)) {
      adLogger.info("購入状態を確認できないまま先へ進みます")
    }

    // Pro を買った人には ATT も聞かず、SDK の初期化もしない。広告を出さないのにトラッキングの許可を
    // 求めるのは筋が通らない。
    if purchase.proUnlocked {
      adLogger.info("Pro を購入済みのため広告を出しません")
      return false
    }

    // ATT はアプリがアクティブになるまで要求されない(TrackingAuthorizer が待つ)。ダイアログを
    // 出せなかった場合もここは戻り、非パーソナライズ広告として初期化へ進む。出し直しは向こうが引き受ける。
    await tracking.ensureRequested()
    await sdk.start()
    return true
  }
}
