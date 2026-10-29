import EitangochoData
import Foundation
import GRDB
import Observation
import os

/// 直近の同期の失敗。文言は表示側が言語に合わせて組み立てる。
public struct SyncFailure: Sendable, Equatable {
  public var reason: CloudFailureReason
  /// 理由だけでは伝わらない補足(OS が返した説明・想定外の失敗の内容)。
  public var detail: String?

  public init(reason: CloudFailureReason, detail: String? = nil) {
    self.reason = reason
    self.detail = detail
  }
}

/// iCloud 同期の有効 / 無効・実行状態を持ち、いつ同期するかを決める
/// (Flutter 版の SyncNotifier の移植)。同期そのものは SyncService が行う。
///
/// 同期する契機: 起動時(start)/ アクティブ化(最短 60 秒おき)/ ローカルの変更
/// (5 秒まとめる)/ 設定画面の「今すぐ同期」。最新のデータを取得できずに
/// 見送ったときは、加えて 1 回だけ再試行する。
@MainActor @Observable
public final class SyncController {
  /// 設定値のキー。Flutter 版と同じ名前・同じ型で読み書きする(UserDefaults を共有する)。
  static let enabledKey = "syncEnabled"
  /// 最後に成功した同期の日時(epoch ミリ秒の整数)。
  static let lastSyncedAtKey = "syncLastSyncedAt"

  /// 同期を有効にしているか。既定は無効(ユーザーが明示的に入れる)。
  public private(set) var enabled: Bool
  /// 同期の実行中か。
  public private(set) var syncing = false
  /// 最後に成功した同期の日時。まだ一度も成功していなければ nil。
  public private(set) var lastSyncedAt: Date?
  /// 直近の同期の失敗。成功したら消す。
  public private(set) var failure: SyncFailure?

  /// 同期が失敗したときに呼ぶ(計測に理由だけを送るため。OS の説明は送らない)。
  /// 準備待ち(notCurrent)は再試行のたびに呼ぶので、件数ではなくユーザー数で見ること。
  public var onFailure: (CloudFailureReason) -> Void = { _ in }

  private let service: SyncService
  private let database: AppDatabase
  private let defaults: UserDefaults
  private let now: @Sendable () -> Date

  /// ローカルの変更を検知してから同期するまでの待ち時間。
  /// 連続した編集やクイズの連続回答を 1 回の書き戻しにまとめるために置く。
  private let debounce: Duration
  /// アクティブ化で同期する最短の間隔。macOS はウィンドウを行き来するたびに
  /// アクティブになるため、これが無いとフォーカスを移すだけで書き戻しが走る。
  private let resumeMinInterval: TimeInterval
  /// 最新のデータを取得できずに見送ってから、再試行するまでの待ち時間。
  private let notReadyRetryDelay: Duration

  @ObservationIgnored private var localChanges: AnyDatabaseCancellable?
  @ObservationIgnored private var debounceTask: Task<Void, Never>?
  @ObservationIgnored private var retryTask: Task<Void, Never>?
  /// 再試行として実行中の同期か。再試行も見送りになったとき、重ねて予約しないために持つ。
  @ObservationIgnored private var retrying = false

  /// 同期の実行中か(DB の変更通知が届くスレッドから読む用)。
  ///
  /// 同期自身の取り込みで次の同期を予約しないよう、実行中の変更は捨てる
  /// (取り込んだ内容はその同期が最後に書き戻すので取りこぼしにならない)。
  /// 通知を主スレッドに移してから `syncing` を見ると、同期が終わった後に
  /// 届いて捨て損ねることがあるため、通知が来たその場で判定する。
  @ObservationIgnored private let syncingFlag = OSAllocatedUnfairLock(initialState: false)

  /// `debounce` / `resumeMinInterval` / `notReadyRetryDelay` は既定値が本番の値で、
  /// テストからだけ縮める。
  public init(
    service: SyncService,
    database: AppDatabase,
    defaults: UserDefaults = .standard,
    debounce: Duration = .seconds(5),
    resumeMinInterval: TimeInterval = 60,
    notReadyRetryDelay: Duration = .seconds(30),
    now: @escaping @Sendable () -> Date = { .now }
  ) {
    self.service = service
    self.database = database
    self.defaults = defaults
    self.debounce = debounce
    self.resumeMinInterval = resumeMinInterval
    self.notReadyRetryDelay = notReadyRetryDelay
    self.now = now
    enabled = defaults.bool(forKey: Self.enabledKey)
    lastSyncedAt = (defaults.object(forKey: Self.lastSyncedAtKey) as? NSNumber).map {
      Date(timeIntervalSince1970: $0.doubleValue / 1000)
    }
  }

  /// 起動時に呼ぶ。有効なら変更の監視を始め、1 回同期する。
  public func start() async {
    guard enabled else { return }
    watchLocalChanges()
    await syncNow()
  }

  /// 同期の有効 / 無効を切り替える。有効にした直後は 1 回同期する。
  public func setEnabled(_ enabled: Bool) async {
    defaults.set(enabled, forKey: Self.enabledKey)
    self.enabled = enabled
    failure = nil
    if enabled {
      watchLocalChanges()
      await syncNow()
    } else {
      unwatchLocalChanges()
    }
  }

  /// アプリがアクティブになったとき。前回の同期から時間が経っていれば同期する。
  ///
  /// iOS はアプリを終了させずに中断するので、ホームに戻して開き直しても
  /// 起動時の同期は走らない。これが無いと他端末の変更を受け取れない。
  public func appDidBecomeActive() async {
    guard enabled, !syncing else { return }
    if let lastSyncedAt, now().timeIntervalSince(lastSyncedAt) < resumeMinInterval { return }
    await syncNow()
  }

  /// 同期を 1 回行う。無効なとき・実行中は何もしない。
  public func syncNow() async {
    guard enabled, !syncing else { return }
    syncing = true
    syncingFlag.withLock { $0 = true }
    failure = nil
    defer {
      syncing = false
      syncingFlag.withLock { $0 = false }
    }
    do {
      try await service.sync(now: now)
      let syncedAt = now()
      defaults.set(Int64((syncedAt.timeIntervalSince1970 * 1000).rounded(.down)), forKey: Self.lastSyncedAtKey)
      // 他の契機で同期できたので、予約済みの再試行は要らない。
      cancelRetry()
      lastSyncedAt = syncedAt
    } catch let error as CloudError {
      fail(SyncFailure(reason: error.reason, detail: error.detail))
      if error.reason == .notCurrent { scheduleRetry() }
    } catch {
      fail(SyncFailure(reason: .failed, detail: String(describing: error)))
    }
  }

  private func fail(_ failure: SyncFailure) {
    self.failure = failure
    onFailure(failure.reason)
  }

  // MARK: - ローカルの変更の監視

  /// ローカルの変更の監視を始める。
  ///
  /// 検知は単語を変える呼び出し元(登録・編集・削除・学習済みの切り替えなど)ではなく、
  /// DB の変更通知 1 本にまとめる。呼び出し元に散らすと、単語を変える導線を
  /// 足すたびに書き漏らすため。クイズの回答も words の更新なのでここに来る
  /// (受け取る側は lastReviewedAt だけを新しい方に揃え、端末間で出題の一巡を共有する)。
  ///
  /// 同期が有効な間だけ監視する。
  private func watchLocalChanges() {
    guard localChanges == nil else { return }
    let syncingFlag = syncingFlag
    let observation = DatabaseRegionObservation(tracking: Table("words"), Table("deleted_words"))
    localChanges = observation.start(
      in: database.writer,
      onError: { _ in },
      onChange: { [weak self] _ in
        guard !syncingFlag.withLock({ $0 }) else { return }
        Task { @MainActor in self?.scheduleDebouncedSync() }
      })
  }

  private func unwatchLocalChanges() {
    debounceTask?.cancel()
    debounceTask = nil
    cancelRetry()
    localChanges?.cancel()
    localChanges = nil
  }

  private func scheduleDebouncedSync() {
    guard enabled else { return }
    debounceTask?.cancel()
    let debounce = debounce
    debounceTask = Task { [weak self] in
      try? await Task.sleep(for: debounce)
      guard !Task.isCancelled else { return }
      await self?.syncNow()
    }
  }

  // MARK: - 見送ったときの再試行

  /// 見送った同期の再試行を 1 回だけ予約する。
  ///
  /// 再試行も見送りになったら重ねて予約しない。取得が長引いているときに
  /// 再試行を回し続けないためで、以後は通常の契機に任せる。
  private func scheduleRetry() {
    guard !retrying, retryTask == nil else { return }
    let delay = notReadyRetryDelay
    retryTask = Task { [weak self] in
      try? await Task.sleep(for: delay)
      guard !Task.isCancelled, let self else { return }
      self.retryTask = nil
      self.retrying = true
      defer { self.retrying = false }
      await self.syncNow()
    }
  }

  private func cancelRetry() {
    retryTask?.cancel()
    retryTask = nil
  }
}
