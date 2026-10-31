import Foundation
import Testing

@testable import Eitangocho

/// Flutter 版の test/features/ads/data/tracking_authorizer_test.dart を移したもの。
/// 「要求が例外を投げてもアプリを止めない」は移さない(Swift の ATT の要求は例外を投げないため)。
@MainActor
final class TrackingAuthorizerTests {
  private let client = FakeTrackingClient()
  private var active = true

  /// 待ち時間は本番の値のままだとテストが止まるので縮める。`activationTimeout` は「待ちきれずに諦める」
  /// 経路を見るときだけ短くする(既定を短くすると、他のテストが復帰を待てずに偶然通ってしまう)。
  private func makeAuthorizer(activationTimeout: Duration = .seconds(5)) -> TrackingAuthorizer {
    TrackingAuthorizer(
      client: client, isActive: { [unowned self] in active }, activationDelay: .zero,
      activationTimeout: activationTimeout)
  }

  /// 非アクティブから戻る。
  private func becomeActive(_ authorizer: TrackingAuthorizer) async {
    active = true
    authorizer.appDidBecomeActive()
    await pumpEventQueue()
  }

  @Test func 回答済みならダイアログを出さない() async {
    client.settled = true
    let authorizer = makeAuthorizer()

    await authorizer.ensureRequested()

    #expect(client.requestCount == 0)
  }

  @Test func アプリがアクティブになるまで要求しない() async {
    active = false
    let authorizer = makeAuthorizer()

    let requested = Task { await authorizer.ensureRequested() }
    await waitUntil { authorizer.isAwaitingActivation }
    // ここで要求してしまうのが Flutter 版 1.5.0 (5) のリジェクトの原因。
    #expect(client.requestCount == 0)

    await becomeActive(authorizer)
    await requested.value

    #expect(client.requestCount == 1)
  }

  @Test func アクティブ化を待ちきれなくても諦めて要求はする() async {
    active = false
    let authorizer = makeAuthorizer(activationTimeout: .milliseconds(10))

    // 復帰が来ないまま止まり続けると広告がゼロになる。上限で先へ進む。
    await authorizer.ensureRequested()

    #expect(client.requestCount == 1)
  }

  @Test func ダイアログが出なかったら次にアクティブへ戻ったときに出し直す() async {
    client.dialogShows = false
    let authorizer = makeAuthorizer()

    await authorizer.ensureRequested()
    #expect(client.requestCount == 1)

    // 2 回目は出せた、という状況にする。
    client.dialogShows = true
    await becomeActive(authorizer)
    await waitUntil { client.requestCount == 2 }

    #expect(client.requestCount == 2)
    #expect(client.settled)
  }

  @Test func 回答が済んだらアクティブへ戻っても要求し直さない() async {
    let authorizer = makeAuthorizer()

    await authorizer.ensureRequested()
    #expect(client.requestCount == 1)

    await becomeActive(authorizer)

    #expect(client.requestCount == 1)
  }

  @Test func 同時に呼ばれても要求は1回だけ() async {
    let authorizer = makeAuthorizer()

    async let first: Void = authorizer.ensureRequested()
    async let second: Void = authorizer.ensureRequested()
    _ = await (first, second)

    #expect(client.requestCount == 1)
  }
}
