import Foundation

/// 主スレッドに積まれた処理を流し切る(Flutter のテストの `pumpEventQueue` に当たる)。
///
/// モデルが内側で起こしたタスク(購入状態の購読など)の進みを、テストの側から待つのに使う。
/// 何回か譲れば足りる処理だけに使い、時間のかかる処理は `waitUntil` で待つ。
@MainActor
func pumpEventQueue(times: Int = 20) async {
  for _ in 0..<times { await Task.yield() }
}

/// 条件が満たされるまで待つ。上限に達したら戻る(呼び出し側の #expect で落とす)。
@MainActor
func waitUntil(timeout: Duration = .seconds(2), _ condition: () -> Bool) async {
  let deadline = ContinuousClock.now + timeout
  while !condition(), ContinuousClock.now < deadline {
    try? await Task.sleep(for: .milliseconds(1))
  }
}
