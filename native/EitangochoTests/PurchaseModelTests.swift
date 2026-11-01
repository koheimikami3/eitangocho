import Foundation
import Testing

@testable import Eitangocho

/// Flutter 版の test/features/purchase/data/purchase_notifier_test.dart を移したもの。
@MainActor
final class PurchaseModelTests {
  private var client = FakePurchasesClient()
  private let analytics = FakeAnalyticsClient()

  /// `messageDuration` は本番の 2.6 秒だとテストが待てないため縮める。
  private func makeModel(messageDuration: Duration = .milliseconds(10)) -> PurchaseModel {
    PurchaseModel(client: client, analytics: AnalyticsLogger(analytics), messageDuration: messageDuration)
  }

  /// 初期化(configure → 購読 → 価格の取得)が終わり、購入状態が届くまで待つ。
  private func initialized() async -> PurchaseModel {
    let model = makeModel()
    model.start()
    await model.waitUntilInitialized()
    await model.proUnlockedKnown.wait()
    return model
  }

  @Test func 初期化すると価格が入り購入できる状態になる() async {
    let model = await initialized()

    #expect(model.available)
    #expect(model.priceText == "¥600")
    #expect(!model.proUnlocked)
    #expect(client.configureCount == 1)
  }

  @Test func 課金を扱えない環境ではSDKに触れない() async {
    client = FakePurchasesClient(isAvailable: false)
    let model = await initialized()

    #expect(!model.available)
    #expect(client.configureCount == 0)

    await model.buy()

    #expect(client.purchaseCount == 0)
  }

  @Test func 初期化に失敗したらProの欄ごと畳む() async {
    client.configureError = URLError(.notConnectedToInternet)
    let model = await initialized()

    #expect(!model.available)
  }

  @Test func 購入済みの状態は起動時に復元される() async {
    client.initialProUnlocked = true
    let model = await initialized()

    #expect(model.proUnlocked)
  }

  @Test func 購入に成功するとProになる() async {
    let model = await initialized()

    await model.buy()

    #expect(model.proUnlocked)
    #expect(!model.purchasing)
    #expect(!model.purchaseFailed)
  }

  @Test func 購入をキャンセルしても何も表示しない() async {
    client.purchaseOutcome = .cancelled
    let model = await initialized()

    await model.buy()

    #expect(!model.proUnlocked)
    #expect(!model.purchaseFailed)
  }

  @Test func 購入に失敗するとメッセージを出ししばらくして消す() async {
    client.purchaseOutcome = .failed
    let model = await initialized()

    await model.buy()

    #expect(model.purchaseFailed)

    await waitUntil { !model.purchaseFailed }

    #expect(!model.purchaseFailed)
  }

  @Test func 価格が取れていないときは購入させない() async {
    client.priceText = nil
    let model = await initialized()

    await model.buy()

    #expect(client.purchaseCount == 0)
  }

  @Test func 購入済みなら二重に購入しない() async {
    client.initialProUnlocked = true
    let model = await initialized()

    await model.buy()

    #expect(client.purchaseCount == 0)
  }

  @Test func 購入処理中に重ねて押しても購入は1回だけ() async {
    // Flutter 版は画面のテスト(mobile_pro_section_test の「二重に購入しない」)で見ていたもの。
    let gate = OneShotSignal()
    client.purchaseGate = gate
    let model = await initialized()

    let first = Task { await model.buy() }
    await waitUntil { model.purchasing }
    await model.buy()
    gate.fire()
    await first.value

    #expect(client.purchaseCount == 1)
    #expect(model.proUnlocked)
  }

  @Test func 復元の実行中は購入しない() async {
    // 遅れて返った復元の「購入履歴なし」が、先に成立した購入の Pro を取り消さないように。
    let gate = OneShotSignal()
    client.restoreGate = gate
    let model = await initialized()

    let restoring = Task { await model.restore() }
    await waitUntil { model.restoring }
    await model.buy()
    gate.fire()
    await restoring.value

    #expect(client.purchaseCount == 0)
    #expect(model.restoreStatus == .notFound)
  }

  @Test func 購入の実行中は復元しない() async {
    let gate = OneShotSignal()
    client.purchaseGate = gate
    let model = await initialized()

    let buying = Task { await model.buy() }
    await waitUntil { model.purchasing }
    await model.restore()
    gate.fire()
    await buying.value

    #expect(client.restoreCount == 0)
    #expect(model.proUnlocked)
  }

  @Test func 続けて復元しても前の結果の消去が次の確認中を消さない() async {
    let model = makeModel(messageDuration: .milliseconds(100))
    model.start()
    await model.waitUntilInitialized()
    await model.restore()
    #expect(model.restoreStatus == .notFound)

    // 結果が消える前に 2 回目を始め、その応答を待たせる。
    let gate = OneShotSignal()
    client.restoreGate = gate
    let second = Task { await model.restore() }
    await waitUntil { client.restoreCount == 2 }
    try? await Task.sleep(for: .milliseconds(200))

    #expect(model.restoring)
    #expect(model.restoreStatus == .checking)
    gate.fire()
    await second.value
  }

  @Test func 復元に成功するとProになる() async {
    client.restoreResult = true
    let model = await initialized()

    await model.restore()

    #expect(model.proUnlocked)
    #expect(model.restoreStatus == .restored)
    #expect(!model.restoring)
  }

  @Test func 購入履歴が無ければその旨を出す() async {
    let model = await initialized()

    await model.restore()

    #expect(!model.proUnlocked)
    #expect(model.restoreStatus == .notFound)
  }

  @Test func 購入済みでも復元できる() async {
    // 機種変更後の導線のため(Flutter 版は画面のテストで見ていたもの)。
    client.initialProUnlocked = true
    client.restoreResult = true
    let model = await initialized()

    await model.restore()

    #expect(client.restoreCount == 1)
    #expect(model.restoreStatus == .restored)
  }

  @Test func 復元に失敗してもアプリは動き続ける() async {
    client.restoreError = URLError(.notConnectedToInternet)
    let model = await initialized()

    await model.restore()

    #expect(model.restoreStatus == .failed)
    #expect(!model.restoring)
  }

  @Test func SDKの更新通知に追従する() async {
    // 別端末での購入・返金は購入導線を通らない。
    let model = await initialized()

    client.emitProUnlocked(true)
    await waitUntil { model.proUnlocked }

    #expect(model.proUnlocked)

    client.emitProUnlocked(false)
    await waitUntil { !model.proUnlocked }

    #expect(!model.proUnlocked)
  }

  // MARK: - proUnlockedKnown

  @Test func 購入状態の合図はentitlementが届いた時点で立ちそのとき状態も入っている() async {
    client.initialProUnlocked = true
    let model = makeModel()
    model.start()

    await model.proUnlockedKnown.wait()

    #expect(model.proUnlocked)
  }

  @Test func 購入状態の合図は課金を扱えない環境でも立つ() async {
    client = FakePurchasesClient(isAvailable: false)
    let model = makeModel()
    model.start()

    // 待ち手を取り残すと、広告側が確定待ちのまま止まる。
    #expect(await model.proUnlockedKnown.wait(timeout: .seconds(2)))
  }

  @Test func 購入状態の合図は初期化に失敗しても立つ() async {
    client.configureError = URLError(.notConnectedToInternet)
    let model = makeModel()
    model.start()

    #expect(await model.proUnlockedKnown.wait(timeout: .seconds(2)))
  }

  // MARK: - 計測

  @Test func 購入ボタンを押したこととその結果を送る() async {
    let model = await initialized()
    await model.buy()
    client = FakePurchasesClient()
    client.purchaseOutcome = .cancelled
    let cancelled = await initialized()
    await cancelled.buy()

    #expect(
      analytics.eventsNamed("pro_purchase") == [
        ["stage": "tapped"], ["stage": "success"], ["stage": "tapped"], ["stage": "cancelled"],
      ])
  }
}
