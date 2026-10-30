import EitangochoData
import Foundation

/// DB への読み書きを止めておく(メモリ上の DB は読み書きが 1 本の列に並ぶので、読みも止まる)。
///
/// モデルの処理を DB の待ちで止めている間に次の操作を差し込み、競合を決まった順で再現するのに使う。
/// 返した関数を呼ぶと再開する。
func holdDatabase(_ database: AppDatabase) -> @Sendable () -> Void {
  let entered = DispatchSemaphore(value: 0)
  let release = DispatchSemaphore(value: 0)
  let writer = database.writer
  Thread.detachNewThread {
    try? writer.writeWithoutTransaction { _ in
      entered.signal()
      release.wait()
    }
  }
  entered.wait()
  return { release.signal() }
}

/// 起こしたタスクが DB の待ちに入るまで待つ(止めている間は先へ進めないので、多めに待っても結果は変わらない)。
func letTasksReachDatabase() async throws {
  try await Task.sleep(for: .milliseconds(50))
}
