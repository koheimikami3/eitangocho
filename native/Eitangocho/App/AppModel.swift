import EitangochoData
import EitangochoSync
import EitangochoWordInfo
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
    let words: WordStore
    let wordInfo: any WordInfoProvider
    let quiz: QuizModel
    let review: ReviewPrompter
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

  /// 設定。DB に依存しないので、起動の流れより先に読む(配色・倍率を最初の画面から効かせるため)。
  let settings = SettingsStore()

  /// 表示中の画面と検索語。メニューからも触るので、DB を開く前から持つ。
  let shell: MainShellModel

  /// 画面の上に重ねるメニューとダイアログ。
  let overlay = AppOverlay()

  /// 独自イベントの送信口。DB に依存しないので最初に作る(Firebase の初期化もここで行う)。
  let analytics: AnalyticsLogger

  /// ユーザープロパティと screen_view。送った値を起動から終了まで覚えておくため、画面ではなくここで持つ。
  @ObservationIgnored private(set) lazy var analyticsReporter = AnalyticsReporter(analytics)

  /// レビュー依頼の実体。依頼の口(`requestReview`)は画面から渡す(RootView)。
  let reviewClient = StoreReviewClient()

  init() {
    analytics = AnalyticsLogger(FirebaseAnalyticsClient.start())
    shell = MainShellModel(analytics: analytics)
  }

  nonisolated private static let logger = Logger(subsystem: "com.kohei.mikami.eitangocho", category: "startup")
  /// 引き継ぎ(DriftDatabaseImporter)と同じ category。元ファイルのログを並べて読めるようにする。
  nonisolated private static let migrationLogger = Logger(
    subsystem: "com.kohei.mikami.eitangocho", category: "migration")

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
      } catch DatabaseImportError.destinationEmpty {
        // 引き継いだ DB を開けないのと同じ扱いにし、失敗の画面に「引き継ぎ直す」を出す。
        return .failure(.openFailed(String(describing: DatabaseImportError.destinationEmpty)))
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
      // 元ファイルは引き継いだ後も変えない決まり。Release ビルドには診断画面が無いので、
      // 起動のたびに状態を出し、引き継ぎのときのログ(サイズ・日時)と比べられるようにする。
      let source = DriftDatabaseImporter.sourceFileState(at: locations.source)
      Self.migrationLogger.info(
        """
        元ファイル: exists=\(source.exists) size=\(source.size ?? -1) \
        modified=\(source.modifiedAt?.description ?? "-", privacy: .public) \
        sidecars=\(source.sidecars.joined(separator: ","), privacy: .public)
        """)
      #if os(macOS)
        // macOS は前面に戻るたびに必ず同期する(ほかの端末の変更を戻ったその場で見られるように)。
        // 書き戻しが増える分、iCloud の競合版はできやすくなるが、次の同期で取り込んで片付ける。
        let resumeMinInterval: TimeInterval = 0
      #else
        // iOS の間隔は iOS の画面を作るときに決める。
        let resumeMinInterval: TimeInterval = 60
      #endif
      let sync = SyncController(
        service: SyncService(store: ICloudFileStore(), database: database), database: database,
        resumeMinInterval: resumeMinInterval)
      sync.onFailure = { [analytics] reason in analytics.logSyncFailed(reason) }
      let words = WordStore(dao: database.wordDao, analytics: analytics)
      words.start()
      let review = ReviewPrompter(client: reviewClient, dao: database.wordDao, analytics: analytics)
      phase = .ready(
        Session(
          database: database, sync: sync, importOutcome: outcome, locations: locations, words: words,
          wordInfo: makeWordInfoProvider(database),
          quiz: QuizModel(dao: database.wordDao, analytics: analytics, review: review) { [words] in
            WordListing.learned(words.words)
          },
          review: review))
      await sync.start()
    }
  }

  /// 単語情報の自動取得。EJDict の初回の取り込みは起動直後にバックグラウンドで始め、
  /// 自動入力の側はその完了を待ってから引く(取り込み中に自動入力された場合に備える)。
  private func makeWordInfoProvider(_ database: AppDatabase) -> any WordInfoProvider {
    let ejdictDao = database.ejdictDao
    let source = Bundle.main.url(forResource: "ejdict-hand-utf8", withExtension: "txt")
    let ejdictImport = Task.detached {
      guard let source else { return }
      do {
        try await EjdictImporter.importIfNeeded(dao: ejdictDao, source: source)
      } catch {
        Self.logger.error("EJDict の取り込みに失敗: \(String(describing: error), privacy: .public)")
      }
    }
    // URLSession はアプリの生存期間で 1 つ共有する(接続を使い回すため)。
    let session = URLSession(configuration: .default)
    let settings = settings
    return DictionaryWordInfoProvider(
      kaikkiClient: KaikkiClient(session: session),
      tatoebaClient: TatoebaClient(session: session),
      deeplClient: DeeplClient(session: session),
      cacheDao: database.dictionaryCacheDao,
      ejdictDao: ejdictDao,
      ensureEjdictImported: { await ejdictImport.value },
      getDeeplApiKey: { await settings.deeplApiKey },
      getTranslationLanguage: { await settings.translationLanguage }
    )
  }

  /// アプリがアクティブになったとき。
  func appDidBecomeActive() async {
    guard case .ready(let session) = phase else { return }
    await session.sync.appDidBecomeActive()
  }
}
