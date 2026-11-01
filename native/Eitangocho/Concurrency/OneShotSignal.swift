import Foundation

/// 一度だけ立つ合図。待っている側を全員まとめて起こす(Flutter 版の `Completer<void>` に当たる)。
///
/// 課金の「購入状態が分かった」(`PurchaseModel.proUnlockedKnown`)と、ATT の「アプリがアクティブになった」
/// (`TrackingAuthorizer`)を待つのに使う。上限つきで待てる(`wait(timeout:)`)のが `Task` で代えない理由
/// (待っている側を打ち切っても、合図を立てる側には影響しない)。
final class OneShotSignal {
  private(set) var isFired = false
  private var waiters: [UUID: CheckedContinuation<Void, Never>] = [:]

  /// 合図を立てる。2 回目以降は何もしない。
  func fire() {
    guard !isFired else { return }
    isFired = true
    let pending = waiters.values
    waiters = [:]
    for waiter in pending { waiter.resume() }
  }

  /// 合図が立つまで待つ。待っているタスクが取り消されたら、その時点で戻る。
  func wait() async {
    if isFired { return }
    let id = UUID()
    await withTaskCancellationHandler {
      await withCheckedContinuation { continuation in
        if isFired || Task.isCancelled {
          continuation.resume()
        } else {
          waiters[id] = continuation
        }
      }
    } onCancel: {
      Task { @MainActor in self.cancelWaiter(id) }
    }
  }

  /// 上限つきで待つ。合図が立てば true、上限に達したら false。
  func wait(timeout: Duration) async -> Bool {
    if isFired { return true }
    return await withTaskGroup(of: Bool.self) { group in
      group.addTask { await self.wait(); return true }
      group.addTask {
        try? await Task.sleep(for: timeout)
        return false
      }
      let fired = await group.next() ?? false
      group.cancelAll()
      return fired
    }
  }

  private func cancelWaiter(_ id: UUID) {
    waiters.removeValue(forKey: id)?.resume()
  }
}
