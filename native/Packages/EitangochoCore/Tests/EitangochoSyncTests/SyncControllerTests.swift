import EitangochoData
import Foundation
import Testing

@testable import EitangochoSync

/// Flutter 版の test/features/sync/data/sync_notifier_test.dart の移植。
@MainActor
final class SyncControllerTests {
  let database: AppDatabase
  let store = InMemoryCloudFileStore()
  let defaults: UserDefaults
  let suiteName = "SyncControllerTests-\(UUID().uuidString)"

  init() throws {
    database = try AppDatabase.inMemory()
    defaults = UserDefaults(suiteName: suiteName)!
  }

  deinit {
    UserDefaults.standard.removePersistentDomain(forName: suiteName)
  }

  /// 待ち時間は本番の 5 秒・60 秒・30 秒だとテストが待てないため、
  /// 契機を確かめるテストからだけ縮める。
  private func makeController(
    debounce: Duration = .seconds(5),
    resumeMinInterval: TimeInterval = 60,
    notReadyRetryDelay: Duration = .seconds(30)
  ) -> SyncController {
    SyncController(
      service: SyncService(store: store, database: database), database: database, defaults: defaults,
      debounce: debounce, resumeMinInterval: resumeMinInterval, notReadyRetryDelay: notReadyRetryDelay)
  }

  /// 条件が満たされるまで待つ(タイマーと DB の変更通知は非同期に届くため)。
  private func waitUntil(_ condition: () -> Bool, timeout: Duration = .seconds(2)) async {
    let deadline = ContinuousClock.now + timeout
    while !condition(), ContinuousClock.now < deadline {
      try? await Task.sleep(for: .milliseconds(10))
    }
  }

  @Test("既定は無効で、無効なうちは同期を実行しない")
  func disabledByDefault() async {
    let controller = makeController()

    #expect(!controller.enabled)
    await controller.syncNow()

    #expect(store.writeCount == 0)
  }

  @Test("有効にすると 1 回同期し、最終同期日時が入る")
  func enablingSyncsOnce() async throws {
    try await database.wordDao.insertWord(NewWord(word: "apple", meaning: "りんご"))
    let controller = makeController()

    await controller.setEnabled(true)

    #expect(controller.enabled)
    #expect(!controller.syncing)
    #expect(controller.lastSyncedAt != nil)
    #expect(controller.failure == nil)
    #expect(store.writeCount == 1)
  }

  @Test("iCloud が使えないときは失敗の理由を保持し、落ちない")
  func keepsFailureReason() async {
    store.readError = CloudError(.noICloud)
    let controller = makeController()

    await controller.setEnabled(true)

    #expect(!controller.syncing)
    #expect(controller.failure == SyncFailure(reason: .noICloud))
    #expect(controller.lastSyncedAt == nil)
  }

  @Test("失敗したら理由だけを渡す(OS の説明は渡さない)")
  func reportsOnlyReason() async {
    store.readError = CloudError(.noICloud, detail: "ユーザーのパスを含みうる説明")
    let controller = makeController()
    var reported: [CloudFailureReason] = []
    controller.onFailure = { reported.append($0) }

    await controller.setEnabled(true)

    #expect(reported == [.noICloud])
  }

  // MARK: - 最新のデータを取得できずに見送ったとき

  @Test("見送ったら失敗の理由を持ち、1 回だけ再試行する")
  func retriesOnceWhenNotCurrent() async {
    store.readError = .notCurrent
    let controller = makeController(notReadyRetryDelay: .milliseconds(50))

    await controller.setEnabled(true)
    #expect(controller.failure?.reason == .notCurrent)
    #expect(store.readCount == 1)

    // 再試行も見送りになるが、それ以上は予約しない。
    try? await Task.sleep(for: .milliseconds(300))
    #expect(store.readCount == 2)
    #expect(store.writeCount == 0)
  }

  @Test("再試行で同期できればエラーが消える")
  func retryClearsFailure() async {
    store.readError = .notCurrent
    let controller = makeController(notReadyRetryDelay: .milliseconds(50))
    await controller.setEnabled(true)

    store.readError = nil
    await waitUntil { controller.lastSyncedAt != nil }

    #expect(controller.failure == nil)
    #expect(store.writeCount == 1)
  }

  @Test("無効にしたら予約済みの再試行は走らない")
  func disablingCancelsRetry() async {
    store.readError = .notCurrent
    let controller = makeController(notReadyRetryDelay: .milliseconds(50))
    await controller.setEnabled(true)

    await controller.setEnabled(false)
    try? await Task.sleep(for: .milliseconds(200))

    #expect(store.readCount == 1)
  }

  // MARK: - ローカルの変更の契機

  @Test("有効なら単語の追加後にまとめて同期する")
  func syncsAfterLocalChange() async throws {
    let controller = makeController(debounce: .zero)
    await controller.setEnabled(true)
    #expect(store.writeCount == 1, "有効にしたときの 1 回")

    try await database.wordDao.insertWord(NewWord(word: "apple", meaning: "りんご"))
    await waitUntil { store.writeCount == 2 }

    #expect(store.writeCount == 2)
  }

  @Test("無効なら単語を追加しても同期しない")
  func ignoresLocalChangeWhenDisabled() async throws {
    _ = makeController(debounce: .zero)

    try await database.wordDao.insertWord(NewWord(word: "apple", meaning: "りんご"))
    try? await Task.sleep(for: .milliseconds(100))

    #expect(store.writeCount == 0)
  }

  @Test("連続した変更は 1 回の同期にまとめられる")
  func debouncesBurstOfChanges() async throws {
    let controller = makeController(debounce: .milliseconds(50))
    await controller.setEnabled(true)

    let id = try await database.wordDao.insertWord(NewWord(word: "apple", meaning: "りんご"))
    try await database.wordDao.setLearned(id: id, true)
    try await database.wordDao.deleteWord(id: id)
    try? await Task.sleep(for: .milliseconds(300))

    #expect(store.writeCount == 2, "有効にしたとき + まとめた 1 回")
  }

  @Test("同期自身の取り込みでは次の同期を予約しない")
  func ignoresOwnImports() async throws {
    store.contents = snapshot(words: [("remote", "リモート", nil)])
    store.modifiedAt = .now
    let controller = makeController(debounce: .zero)

    await controller.setEnabled(true)
    try? await Task.sleep(for: .milliseconds(200))

    #expect(try await database.wordDao.getAll().map(\.word) == ["remote"])
    #expect(store.writeCount == 1)
  }

  // MARK: - アクティブ化の契機

  @Test("最短間隔を過ぎていればアクティブ化で同期する")
  func syncsOnActivation() async {
    let controller = makeController(resumeMinInterval: 0)
    await controller.setEnabled(true)

    await controller.appDidBecomeActive()

    #expect(store.writeCount == 2)
  }

  @Test("最短間隔内のアクティブ化では同期しない")
  func skipsActivationWithinInterval() async {
    let controller = makeController(resumeMinInterval: 600)
    await controller.setEnabled(true)

    await controller.appDidBecomeActive()

    #expect(store.writeCount == 1, "有効にしたときの 1 回だけ")
  }

  @Test("無効ならアクティブ化しても同期しない")
  func skipsActivationWhenDisabled() async {
    let controller = makeController(resumeMinInterval: 0)

    await controller.appDidBecomeActive()

    #expect(store.writeCount == 0)
  }

  // MARK: - 永続化

  @Test("有効 / 無効と最終同期日時は Flutter 版と同じキー・型で保存され、次の起動で戻る")
  func persistsWithFlutterKeys() async {
    let controller = makeController()
    await controller.setEnabled(true)

    #expect(defaults.object(forKey: "syncEnabled") as? Bool == true)
    let millis = defaults.object(forKey: "syncLastSyncedAt") as? NSNumber
    #expect(millis != nil)
    #expect(millis.map { CFNumberIsFloatType($0) } == false)

    let restored = makeController()
    #expect(restored.enabled)
    #expect(restored.lastSyncedAt.map { Int64($0.timeIntervalSince1970 * 1000) } == millis?.int64Value)
  }

  @Test("起動時は有効なら 1 回同期し、無効なら何もしない")
  func startSyncsOnlyWhenEnabled() async {
    await makeController().start()
    #expect(store.writeCount == 0)

    defaults.set(true, forKey: "syncEnabled")
    await makeController().start()
    #expect(store.writeCount == 1)
  }
}
