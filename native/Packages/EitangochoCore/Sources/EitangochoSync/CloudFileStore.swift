import Foundation

/// クラウド上の 1 ファイルを読み書きする抽象。
///
/// 同期は「アプリのクラウドコンテナに置いた JSON スナップショット 1 個」で
/// 成り立つため、操作はそのファイルの読み書きと、その競合版の扱いだけに絞ってある。
/// 実装は iCloud Drive(ICloudFileStore)。テストではメモリ上の実装を渡す。
public protocol CloudFileStore: Sendable {
  /// ファイルの内容。まだ無ければ nil。
  func read() async throws -> String?

  /// ファイルを書く(無ければ作る)。
  func write(_ contents: String) async throws

  /// ファイルの最終更新日時。無ければ nil。
  ///
  /// 書く直前に読み取り時から変わっていないかを確かめ、他端末の書き込みを
  /// 踏み潰さないために使う(SyncService)。
  func lastModified() async throws -> Date?

  /// 未解決の競合版。無ければ空。
  ///
  /// ある端末が古い内容で上書きすると、他端末の新しい版は現行版から外れて
  /// 競合版として残る。SyncService はこれも取り込み、変更の取りこぼしを防ぐ。
  func readConflicts() async throws -> [CloudConflict]

  /// readConflicts で得た競合版のうち、`ids` のものだけを解決済みにして消す。
  ///
  /// id で指定するのは、読み取り後に届いた(まだ取り込んでいない)競合版を
  /// 巻き込んで消さないため。
  func resolveConflicts(_ ids: [String]) async throws
}

/// 同期ファイルの競合版 1 つ。
public struct CloudConflict: Sendable, Equatable {
  /// CloudFileStore.resolveConflicts に渡す識別子。
  public var id: String
  /// 競合版のファイルの内容(同期ファイルと同じ JSON)。
  public var contents: String
  /// 競合版が書かれた日時。取れなければ nil。
  public var modifiedAt: Date?

  public init(id: String, contents: String, modifiedAt: Date?) {
    self.id = id
    self.contents = contents
    self.modifiedAt = modifiedAt
  }
}

/// 同期が失敗した理由。計測の `sync_failed` の値もこれから決まる。
public enum CloudFailureReason: String, Sendable, Equatable {
  /// iCloud Drive にサインインしていないなど、iCloud を使えない。
  case noICloud
  /// 端末のコピーを最新にできず、同期を見送った。一時的なので少し待って再試行する。
  case notCurrent
  /// iCloud に対応していないプラットフォーム。
  case unsupportedPlatform
  /// それ以外(読み書きの失敗など)。
  case failed
}

/// クラウドが使えないときの失敗。
///
/// 文言は持たせず、`reason` から表示側が言語に合わせて出す。
/// `detail` は OS が返した説明など、理由だけでは伝わらない補足(あれば)。
public struct CloudError: Error, Sendable, Equatable {
  public var reason: CloudFailureReason
  public var detail: String?

  public init(_ reason: CloudFailureReason, detail: String? = nil) {
    self.reason = reason
    self.detail = detail
  }

  /// 端末のコピーがクラウドの最新版にならず、同期を見送った。
  ///
  /// 古いコピーを読んで書き戻すと、他端末の新しい版を踏み潰して競合版に追いやるため、
  /// 最新化を待ちきれなかったときは読み書きせずにこれを投げる。
  public static let notCurrent = CloudError(.notCurrent)
}
