import Foundation

@testable import Eitangocho

/// SDK に触れない PurchasesClient(Flutter 版の FakePurchasesClient)。
///
/// テストは macOS で動き、macOS には課金の SDK をリンクしていないため、購入まわりの検証はすべて
/// これに差し替えて行う。
final class FakePurchasesClient: PurchasesClient {
  let isAvailable: Bool
  /// 取得できる価格。nil なら「商品を引けなかった」を表す。
  var priceText: String? = "¥600"
  /// 購読を始めた時点の購入状態。
  var initialProUnlocked = false
  var purchaseOutcome = PurchaseOutcome.purchased
  var restoreResult = false
  /// 投げさせたい例外。
  var configureError: (any Error)?
  var restoreError: (any Error)?

  /// 購入を途中で止めておくための関門。App Store のダイアログが出ている間(= 処理中の表示)を
  /// 再現したいテストだけ使う。
  var purchaseGate: OneShotSignal?
  /// 復元を途中で止めておくための関門。購入と復元が重なったときの挙動を見たいテストだけ使う。
  var restoreGate: OneShotSignal?
  /// 初期化を途中で止めておくための関門。購入状態がまだ確定していない間の挙動を見たいテストだけ使う。
  var configureGate: OneShotSignal?

  private(set) var configureCount = 0
  private(set) var purchaseCount = 0
  private(set) var restoreCount = 0

  private var continuations: [AsyncStream<Bool>.Continuation] = []

  init(isAvailable: Bool = true, initialProUnlocked: Bool = false) {
    self.isAvailable = isAvailable
    self.initialProUnlocked = initialProUnlocked
  }

  /// SDK 側からの更新通知(別端末での購入・返金)を模す。
  func emitProUnlocked(_ unlocked: Bool) {
    for continuation in continuations { continuation.yield(unlocked) }
  }

  func configure() async throws {
    configureCount += 1
    await configureGate?.wait()
    if let configureError { throw configureError }
  }

  func proUnlockedUpdates() -> AsyncStream<Bool> {
    let (stream, continuation) = AsyncStream.makeStream(of: Bool.self)
    continuation.yield(initialProUnlocked)
    continuations.append(continuation)
    return stream
  }

  func fetchPriceText() async -> String? { priceText }

  func purchase() async -> PurchaseOutcome {
    purchaseCount += 1
    await purchaseGate?.wait()
    return purchaseOutcome
  }

  func restore() async throws -> Bool {
    restoreCount += 1
    await restoreGate?.wait()
    if let restoreError { throw restoreError }
    return restoreResult
  }
}
