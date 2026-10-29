import EitangochoData
import EitangochoSync
import Foundation
import Observation
import OSLog

/// 起動の流れ(Flutter 版の DB の引き継ぎ → DB を開く → 同期を始める)と、その結果を持つ。
///
/// 引き継ぎに失敗したら空の DB では始めず、失敗の画面を出す
/// (docs/design.md「データ・同期」)。
@Observable
final class AppModel {
  enum Phase {
    case loading
    case ready(Session)
    case failed(StartupFailure)
  }

  /// 起動に成功した後に画面が使うもの。
  struct Session {
    let database: AppDatabase
    let sync: SyncController
    let importOutcome: DatabaseImportOutcome
    let locations: DriftDatabaseImporter.Locations
  }

  /// 起動の失敗。
  enum StartupFailure: Error {
    /// App Group のコンテナを取れない(entitlements・プロビジョニングの不備)。
    case appGroupUnavailable
    /// Flutter 版の DB を引き継げなかった。元ファイルは無傷なので、やり直せる。
    case importFailed(DatabaseImportError)
    /// 引き継いだ DB を開けなかった。元ファイルから引き継ぎ直せる。
    case openFailed(String)
  }

  private(set) var phase: Phase = .loading

  private static let logger = Logger(subsystem: "com.kohei.mikami.eitangocho", category: "startup")

  /// App Group の ID。Bundle ID に `group.` を付けたもの(Debug は .dev 付きで本番と分かれる)。
  static var appGroupIdentifier: String {
    "group." + (Bundle.main.bundleIdentifier ?? "com.kohei.mikami.eitangocho")
  }

  /// 起動の流れを最初から行う(失敗の画面の「再試行」もこれを呼ぶ)。
  func start() async {
    await open { importer in try importer.run() }
  }

  /// 引き継いだ DB を別名で残し、Flutter 版の DB から引き継ぎ直す(失敗の画面から呼ぶ)。
  func reimport() async {
    await open { importer in try importer.reimport() }
  }

  private func open(
    _ runImport: @escaping @Sendable (DriftDatabaseImporter) throws -> DatabaseImportOutcome
  ) async {
    phase = .loading
    guard let locations = DriftDatabaseImporter.Locations.standard(appGroupIdentifier: Self.appGroupIdentifier)
    else {
      phase = .failed(.appGroupUnavailable)
      return
    }
    Self.logger.info("DB: \(locations.destination.path, privacy: .public)")

    // ファイルのコピーと検証は主スレッドの外で行う。
    let result = await Task.detached { () -> Result<(DatabaseImportOutcome, AppDatabase), StartupFailure> in
      let outcome: DatabaseImportOutcome
      do {
        outcome = try runImport(DriftDatabaseImporter(locations: locations))
      } catch let error as DatabaseImportError {
        return .failure(.importFailed(error))
      } catch {
        return .failure(.importFailed(.copyFailed(String(describing: error))))
      }
      do {
        return .success((outcome, try AppDatabase.open(at: locations.destination)))
      } catch {
        return .failure(.openFailed(String(describing: error)))
      }
    }.value

    switch result {
    case .failure(let failure):
      Self.logger.error("起動に失敗: \(String(describing: failure), privacy: .public)")
      phase = .failed(failure)
    case .success(let (outcome, database)):
      let sync = SyncController(service: SyncService(store: ICloudFileStore(), database: database), database: database)
      phase = .ready(Session(database: database, sync: sync, importOutcome: outcome, locations: locations))
      await sync.start()
    }
  }

  /// アプリがアクティブになったとき。
  func appDidBecomeActive() async {
    guard case .ready(let session) = phase else { return }
    await session.sync.appDidBecomeActive()
  }
}
