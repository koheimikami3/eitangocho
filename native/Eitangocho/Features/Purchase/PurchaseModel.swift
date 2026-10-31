import Foundation
import Observation
import SwiftUI

/// 復元の状況(復元行の右端に一時表示する)。文言は表示側が言語に合わせて出す。
enum RestoreStatus {
  case checking, restored, notFound, failed
}

/// 「広告を非表示にする」買い切りの購入状態を持つ(Flutter 版の PurchaseNotifier + PurchaseState)。
/// 設定画面の Pro の欄にそのまま使う。
///
/// 状態の出所は 2 つある。SDK の更新通知(`PurchasesClient.proUnlockedUpdates`)と、このアプリ自身の
/// 購入・復元。前者を張り続けるのは、返金・別端末での購入が購入導線を通らずに起きるため。
///
/// 課金の失敗でアプリを止めない(辞書・広告と同じ方針)。買えなければ広告が出たままになるだけで、
/// 単語帳としては使える。
@Observable
final class PurchaseModel {
  /// 課金を扱える環境か(iOS かつ SDK キーが設定済み)。false のときは設定画面に Pro の欄ごと出さない。
  private(set) var available: Bool
  /// Pro が解禁されているか。広告の出し分けはこの 1 点で決まる。
  private(set) var proUnlocked = false
  /// 買い切り商品の表示価格(`¥300` のようにローカライズ済みの文字列)。取得前・取得失敗は nil。
  /// 価格が無いときは購入させない。
  private(set) var priceText: String?
  /// 購入処理の実行中か。
  private(set) var purchasing = false
  /// 復元処理の実行中か。
  private(set) var restoring = false
  /// 購入に失敗した(購入行に一時表示する)。
  private(set) var purchaseFailed = false
  /// 復元行の右端に一時表示する状況。
  private(set) var restoreStatus: RestoreStatus?

  /// 購入状態(entitlement)が一度でも分かったことを表す合図。
  ///
  /// 広告側が「Pro を買った人には ATT を聞かない」を実際に効かせるために待つ。`proUnlocked` の
  /// 初期値 false を鵜呑みにすると、購入者にも毎起動トラッキング許可を求めてしまう。
  ///
  /// 価格の取得までは待たない(`initialization` との違い)。entitlement とは別の問い合わせで、
  /// 遅い方に引きずられると ATT がそのぶん遅れるため。
  ///
  /// 「分かった」には諦めも含む。課金が使えない環境・初期化の失敗でも立てる。待ち手を取り残すと
  /// 広告そのものが出なくなる。
  @ObservationIgnored let proUnlockedKnown = OneShotSignal()

  @ObservationIgnored private let client: any PurchasesClient
  @ObservationIgnored private let analytics: AnalyticsLogger
  /// 購入・復元の結果メッセージを出しておく時間(デザイン準拠)。
  @ObservationIgnored private let messageDuration: Duration
  @ObservationIgnored private var initialization: Task<Void, Never>?
  @ObservationIgnored private var updates: Task<Void, Never>?
  @ObservationIgnored private var messageClear: Task<Void, Never>?

  /// `messageDuration` は既定値が本番の値で、テストからだけ縮める。
  init(client: any PurchasesClient, analytics: AnalyticsLogger, messageDuration: Duration = .milliseconds(2600)) {
    self.client = client
    self.analytics = analytics
    self.messageDuration = messageDuration
    available = client.isAvailable
  }

  /// SDK を初期化し、購入状態の購読と価格の取得を始める。2 回目以降は何もしない。
  func start() {
    guard initialization == nil else { return }
    initialization = Task { await initialize() }
  }

  /// 初期化(価格の取得まで)が終わるまで待つ。
  func waitUntilInitialized() async {
    await initialization?.value
  }

  /// 初期化に失敗したら購入も復元もできないため、Pro の欄ごと畳む(`available` を false に戻す)。
  /// 押しても何も起きないボタンを残すより、無い方が分かりやすい。
  private func initialize() async {
    guard client.isAvailable else {
      purchaseLogger.info("課金は無効です(iOS 以外、または SDK キーが未設定)")
      proUnlockedKnown.fire()
      return
    }

    do {
      try await client.configure()
    } catch {
      purchaseLogger.error("SDK の初期化に失敗しました: \(String(describing: error), privacy: .public)")
      available = false
      proUnlockedKnown.fire()
      return
    }

    let stream = client.proUnlockedUpdates()
    updates = Task { [weak self] in
      for await unlocked in stream {
        guard let self else { return }
        proUnlockedKnown.fire()
        purchaseLogger.info("購入状態: \(unlocked ? "Pro" : "未購入", privacy: .public)")
        proUnlocked = unlocked
      }
    }

    priceText = await client.fetchPriceText()
  }

  /// 買い切り商品を購入する。
  ///
  /// 価格が取れていないときは何もしない(商品が引けていない = 購入もできない)。
  func buy() async {
    await waitUntilInitialized()
    guard available, !purchasing, !proUnlocked, priceText != nil else { return }

    purchasing = true
    purchaseFailed = false
    analytics.logProPurchase(.tapped)
    let outcome = await client.purchase()

    purchasing = false
    switch outcome {
    case .purchased:
      proUnlocked = true
      analytics.logProPurchase(.success)
    case .cancelled:
      // ダイアログを閉じただけなので何も出さない。
      analytics.logProPurchase(.cancelled)
    case .failed:
      purchaseFailed = true
      analytics.logProPurchase(.failed)
      scheduleMessageClear()
    }
  }

  /// 過去の購入を復元する。
  ///
  /// 機種変更・再インストールで購入が消えた人のための導線なので、購入済みに見えているかどうかに
  /// 関わらず実行できる。結果は復元の判断そのもの(RevenueCat が返す entitlement)で上書きする。
  func restore() async {
    await waitUntilInitialized()
    guard available, !restoring else { return }

    restoring = true
    restoreStatus = .checking
    do {
      let unlocked = try await client.restore()
      proUnlocked = unlocked
      restoreStatus = unlocked ? .restored : .notFound
    } catch {
      purchaseLogger.error("復元に失敗しました: \(String(describing: error), privacy: .public)")
      restoreStatus = .failed
    }
    restoring = false
    scheduleMessageClear()
  }

  /// 一時表示のメッセージを消す。
  private func scheduleMessageClear() {
    messageClear?.cancel()
    messageClear = Task { [weak self, messageDuration] in
      try? await Task.sleep(for: messageDuration)
      guard !Task.isCancelled, let self else { return }
      purchaseFailed = false
      restoreStatus = nil
    }
  }
}

extension EnvironmentValues {
  /// 課金の状態(広告の枠・Pro の欄が読む)。RootView が配る。
  @Entry var purchase: PurchaseModel?
}
