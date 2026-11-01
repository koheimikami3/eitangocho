import Foundation
import Testing

@testable import Eitangocho

/// Flutter 版の test/features/ads/data/ads_provider_test.dart を移したもの。
@MainActor
final class AdsControllerTests {
  private let client = FakePurchasesClient(initialProUnlocked: true)
  private let tracking = FakeTrackingClient()
  private let sdk = FakeAdsSDK()

  /// テストは macOS で動くので、広告を出す OS として扱わせる(Flutter 版は対象の OS を iOS に差し替えていた)。
  private func makeController() -> (AdsController, PurchaseModel) {
    let purchase = PurchaseModel(client: client, analytics: AnalyticsLogger(NoopAnalyticsClient()))
    purchase.start()
    let authorizer = TrackingAuthorizer(client: tracking, isActive: { true }, activationDelay: .zero)
    let controller = AdsController(
      purchase: purchase, tracking: authorizer, sdk: sdk, platformSupported: true, hasAnyUnit: true)
    return (controller, purchase)
  }

  @Test func Proを購入済みならATTもSDKの初期化もせずに広告を止める() async {
    let (controller, purchase) = makeController()

    #expect(await controller.isEnabled() == false)
    #expect(purchase.proUnlocked)
    #expect(tracking.requestCount == 0)
    #expect(sdk.startCount == 0)
  }

  @Test func 購入状態が確定するまでATTを要求しない() async {
    // entitlement が届くのを遅らせて、確定前に ATT を聞かないことを見る。待たずに読むと proUnlocked の
    // 初期値 false を鵜呑みにしてしまい、Pro 購入者にもトラッキング許可を求めることになる。
    let configured = OneShotSignal()
    client.configureGate = configured
    let (controller, _) = makeController()

    let enabled = Task { await controller.isEnabled() }
    await pumpEventQueue()
    #expect(tracking.isSettledCount == 0)
    #expect(tracking.requestCount == 0)

    configured.fire()

    #expect(await enabled.value == false)
    #expect(tracking.requestCount == 0)
  }

  @Test func 未購入ならATTを聞いてからSDKを初期化し以後は同じ値を返す() async {
    client.initialProUnlocked = false
    let (controller, _) = makeController()

    #expect(await controller.isEnabled())
    #expect(await controller.isEnabled())

    #expect(tracking.requestCount == 1)
    #expect(sdk.startCount == 1)
  }
}
