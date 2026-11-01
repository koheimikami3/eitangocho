import Foundation

@testable import Eitangocho

/// OS に触れない TrackingClient(Flutter 版の FakeTrackingClient)。
final class FakeTrackingClient: TrackingClient {
  /// 許可の状態が確定済みか。`request` が成功すると true になる。
  var settled = false
  /// `request` でダイアログが出るか。false は「非アクティブ中に呼んだので出ないまま返った」を模す。
  var dialogShows = true
  /// `statusName` が返す状態。
  var status = "not_determined"
  /// `request` の中(結果を返す前)に呼ぶ。要求の最中に起きることを差し込む。
  var onRequest: () -> Void = {}
  /// 要求を途中で止めておくための関門。ダイアログが出ている間に起きることを見たいテストだけ使う。
  var requestGate: OneShotSignal?

  private(set) var isSettledCount = 0
  private(set) var requestCount = 0

  func isSettled() async -> Bool {
    isSettledCount += 1
    return settled
  }

  func request() async -> Bool {
    requestCount += 1
    await requestGate?.wait()
    onRequest()
    if dialogShows { settled = true }
    return settled
  }

  func statusName() -> String { status }
}

/// 呼ばれた回数を数えるだけの AdsSDK。
final class FakeAdsSDK: AdsSDK {
  private(set) var startCount = 0

  func start() async {
    startCount += 1
  }
}
