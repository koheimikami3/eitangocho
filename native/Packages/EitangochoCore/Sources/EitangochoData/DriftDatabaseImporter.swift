import Foundation
import GRDB
import OSLog
import SQLite3

/// Flutter 版(drift)の DB ファイルを、Swift 版が使う App Group の場所へ引き継ぐ。
///
/// 既存ユーザーのデータを確実に引き継ぐことを最優先にしているので、次の 3 点を守る
/// (docs/design.md「データ・同期」)。
/// - **元ファイルは開かない・書き換えない。** ファイルとして一時フォルダへコピーし、
///   ホットジャーナルの復旧やスキーマの更新はコピーの方で起こす。元ファイルが
///   残っていれば、Flutter 版を入れ直すだけで引き継いだ時点の内容に戻れる
/// - **確かめ終えたコピーだけを本来の場所へ移す。** 移動は同じボリューム内の
///   不可分な操作なので、途中で落ちても中途半端な DB は残らない
/// - **失敗しても空の DB では始めない。** 印を書かずにエラーを返し、次の起動でやり直す
public struct DriftDatabaseImporter {
  /// 引き継ぎの元と先。
  public struct Locations: Sendable {
    /// Flutter 版の DB(drift_flutter の既定 = Documents/eitangocho.sqlite)。
    public var source: URL
    /// Swift 版の DB(App Group の中)。
    public var destination: URL

    public init(source: URL, destination: URL) {
      self.source = source
      self.destination = destination
    }

    /// アプリが使う既定の場所。App Group を使えなければ nil。
    public static func standard(appGroupIdentifier: String) -> Locations? {
      guard
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
        let group = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
      else { return nil }
      return Locations(
        source: documents.appendingPathComponent(fileName),
        destination: group.appendingPathComponent("Database", isDirectory: true)
          .appendingPathComponent(fileName))
    }
  }

  /// drift_flutter の `driftDatabase(name: 'eitangocho')` が作るファイル名。
  public static let fileName = "eitangocho.sqlite"

  /// SQLite が本体の横に作る付属ファイル。
  static let sidecarSuffixes = ["-journal", "-wal", "-shm"]

  /// 引き継ぎの記録を置く UserDefaults のキー。
  public static let recordKey = "nativeDatabaseImport"

  private static let logger = Logger(subsystem: "com.kohei.mikami.eitangocho", category: "migration")

  public let locations: Locations
  private let defaults: UserDefaults

  /// テスト用の差し込み口。接続を閉じた後、付属ファイルを確かめる前に呼ばれる。
  var afterClose: (URL) throws -> Void = { _ in }

  /// テスト用の差し込み口。一時フォルダの本体を本来の場所へ動かす。
  var moveItem: (URL, URL) throws -> Void = { try FileManager.default.moveItem(at: $0, to: $1) }

  public init(locations: Locations, defaults: UserDefaults = .standard) {
    self.locations = locations
    self.defaults = defaults
  }

  /// 引き継ぎを済ませる。済んでいれば何もしない。
  ///
  /// 戻った後は `locations.destination` を AppDatabase.open で開いてよい。
  /// 新規インストールのときはファイルを作らず、開いたときにスキーマが作られる。
  public func run(now: Date = .now) throws -> DatabaseImportOutcome {
    let fileManager = FileManager.default
    // 本来の場所の DB は、引き継ぎを確かめ終えたコピーか、新規インストールで
    // 作ったものだけ。あればそれを正として使う(印が欠けていても作り直さない。
    // 移動の直後に落ちて印だけ書けなかった場合に、引き継ぎ後の変更を失わないため)。
    if fileManager.fileExists(atPath: locations.destination.path) {
      return .alreadyImported(record)
    }
    try fileManager.createDirectory(
      at: locations.destination.deletingLastPathComponent(), withIntermediateDirectories: true)
    removeLeftoverWorkDirectories()

    guard fileManager.fileExists(atPath: locations.source.path) else {
      let record = DatabaseImportRecord(kind: .freshInstall, importedAt: now)
      save(record)
      Self.logger.info("Flutter 版の DB が無いため新規インストールとして始めます")
      return .performed(record)
    }

    let record = try importSource(now: now)
    save(record)
    return .performed(record)
  }

  /// 引き継いだ DB が開けなくなったときに、元ファイルから引き継ぎ直す。
  ///
  /// 壊れたファイルは消さずに別名で残す(手で取り出せる余地を残すため)。
  /// 引き継ぎ後の変更は失われるが、同期が有効なら iCloud から戻る。
  /// 自動では呼ばない(エラー画面の操作からだけ呼ぶ)。
  public func reimport(now: Date = .now) throws -> DatabaseImportOutcome {
    let fileManager = FileManager.default
    let stamp = Int(now.timeIntervalSince1970)
    for suffix in [""] + Self.sidecarSuffixes {
      let url = URL(fileURLWithPath: locations.destination.path + suffix)
      guard fileManager.fileExists(atPath: url.path) else { continue }
      try fileManager.moveItem(at: url, to: URL(fileURLWithPath: url.path + ".broken-\(stamp)"))
    }
    defaults.removeObject(forKey: Self.recordKey)
    return try run(now: now)
  }

  /// これまでの引き継ぎの記録。無ければ nil。
  public var record: DatabaseImportRecord? {
    guard let data = defaults.data(forKey: Self.recordKey) else { return nil }
    return try? JSONDecoder().decode(DatabaseImportRecord.self, from: data)
  }

  // MARK: - 引き継ぎの本体

  private func importSource(now: Date) throws -> DatabaseImportRecord {
    let fileManager = FileManager.default
    let workDirectory = locations.destination.deletingLastPathComponent()
      .appendingPathComponent("import-\(UUID().uuidString)", isDirectory: true)
    try fileManager.createDirectory(at: workDirectory, withIntermediateDirectories: true)
    defer { try? fileManager.removeItem(at: workDirectory) }

    let attributes = try? fileManager.attributesOfItem(atPath: locations.source.path)
    let sourceSize = (attributes?[.size] as? NSNumber)?.int64Value
    let sourceModifiedAt = attributes?[.modificationDate] as? Date

    // 1. 元ファイルと付属ファイルを、ファイルとしてコピーする(元ファイルは開かない)。
    let copy = workDirectory.appendingPathComponent(Self.fileName)
    var copiedSidecars: [String] = []
    do {
      try fileManager.copyItem(at: locations.source, to: copy)
      for suffix in Self.sidecarSuffixes {
        let sidecar = URL(fileURLWithPath: locations.source.path + suffix)
        guard fileManager.fileExists(atPath: sidecar.path) else { continue }
        try fileManager.copyItem(at: sidecar, to: URL(fileURLWithPath: copy.path + suffix))
        copiedSidecars.append(suffix)
      }
    } catch {
      throw DatabaseImportError.copyFailed(String(describing: error))
    }
    Self.logger.info(
      """
      Flutter 版の DB をコピーしました: \(locations.source.path, privacy: .public) \
      size=\(sourceSize ?? -1) modified=\(sourceModifiedAt?.description ?? "-", privacy: .public) \
      sidecars=\(copiedSidecars.joined(separator: ","), privacy: .public)
      """)

    // 2. コピーを開いて確かめ、drift と同じ手順で最新のスキーマまで上げる。
    //    ホットジャーナルがあれば、ここで(コピーの方で)巻き戻される。
    let queue: DatabaseQueue
    let sourceUserVersion: Int
    let wordCountBefore: Int
    do {
      queue = try DatabaseQueue(path: copy.path)
      (sourceUserVersion, wordCountBefore) = try queue.writeWithoutTransaction { db in
        let check = try String.fetchAll(db, sql: "PRAGMA quick_check")
        guard check == ["ok"] else {
          throw DatabaseImportError.integrityCheckFailed(check.joined(separator: "\n"))
        }
        let version = try AppDatabase.userVersion(db)
        let words = try db.tableExists("words")
          ? try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM words") ?? 0 : 0
        return (version, words)
      }
    } catch let error as DatabaseImportError {
      throw error
    } catch {
      throw DatabaseImportError.openFailed(String(describing: error))
    }

    let counts: DatabaseImportRecord.Counts
    do {
      let database = try AppDatabase(queue)
      counts = try database.writer.read { db in
        func count(_ table: String) throws -> Int {
          try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM \(table)") ?? 0
        }
        return .init(
          words: try count("words"), deletions: try count("deleted_words"),
          ejdict: try count("ejdict_entries"), dictionaryCache: try count("dictionary_cache_entries"))
      }
    } catch {
      throw DatabaseImportError.openFailed(String(describing: error))
    }
    // スキーマの更新は単語の行に触れない。数が変わっていたら何かがおかしいので移さない。
    guard counts.words == wordCountBefore else {
      throw DatabaseImportError.wordCountChanged(before: wordCountBefore, after: counts.words)
    }

    // 3. WAL に切り替え、チェックポイントしてから閉じる。
    //    本体だけを移すので、-wal にしか入っていない書き込みを残してはいけない。
    do {
      try queue.writeWithoutTransaction { db in
        let mode = try String.fetchOne(db, sql: "PRAGMA journal_mode = WAL")
        guard mode?.lowercased() == "wal" else {
          throw DatabaseImportError.walUnavailable(mode ?? "-")
        }
        // Apple の SQLite は WAL を閉じた後も残す(persistent WAL)のが既定なので、
        // この接続だけ切って、閉じたときに -wal / -shm が消えるようにする。
        var persist: Int32 = 0
        let status = sqlite3_file_control(db.sqliteConnection, "main", SQLITE_FCNTL_PERSIST_WAL, &persist)
        guard status == SQLITE_OK else {
          throw DatabaseImportError.walUnavailable("persist_wal: \(status)")
        }
        try db.checkpoint(.truncate)
      }
      try queue.close()
    } catch let error as DatabaseImportError {
      throw error
    } catch {
      throw DatabaseImportError.openFailed(String(describing: error))
    }
    try afterClose(copy)

    // 4. 付属ファイルが残っていないことを確かめてから、本体だけを移す。
    let leftovers = Self.sidecarSuffixes.filter {
      fileManager.fileExists(atPath: copy.path + $0)
    }
    guard leftovers.isEmpty else { throw DatabaseImportError.sidecarsRemain(leftovers) }
    do {
      try moveItem(copy, locations.destination)
    } catch {
      throw DatabaseImportError.moveFailed(String(describing: error))
    }

    Self.logger.info(
      """
      引き継ぎました: user_version=\(sourceUserVersion) words=\(counts.words) \
      deletions=\(counts.deletions) ejdict=\(counts.ejdict)
      """)
    return DatabaseImportRecord(
      kind: .imported, importedAt: now, sourceUserVersion: sourceUserVersion,
      sourceSize: sourceSize, sourceModifiedAt: sourceModifiedAt, sourceSidecars: copiedSidecars,
      counts: counts)
  }

  /// 前回の引き継ぎが途中で落ちたときの一時フォルダを片付ける。
  private func removeLeftoverWorkDirectories() {
    let directory = locations.destination.deletingLastPathComponent()
    let entries = (try? FileManager.default.contentsOfDirectory(atPath: directory.path)) ?? []
    for entry in entries where entry.hasPrefix("import-") {
      try? FileManager.default.removeItem(at: directory.appendingPathComponent(entry))
    }
  }

  private func save(_ record: DatabaseImportRecord) {
    guard let data = try? JSONEncoder().encode(record) else { return }
    defaults.set(data, forKey: Self.recordKey)
  }
}

/// `DriftDatabaseImporter.run` の結果。
public enum DatabaseImportOutcome: Sendable, Equatable {
  /// 前の起動までに済んでいた(記録が読めなければ nil)。
  case alreadyImported(DatabaseImportRecord?)
  /// この起動で引き継いだか、新規インストールとして始めた。
  case performed(DatabaseImportRecord)
}

/// 引き継ぎの記録(診断画面とログ用)。
public struct DatabaseImportRecord: Codable, Sendable, Equatable {
  public enum Kind: String, Codable, Sendable {
    /// Flutter 版の DB を引き継いだ。
    case imported
    /// Flutter 版の DB が無く、新規インストールとして始めた。
    case freshInstall
  }

  public struct Counts: Codable, Sendable, Equatable {
    public var words: Int
    public var deletions: Int
    public var ejdict: Int
    public var dictionaryCache: Int
  }

  public var kind: Kind
  public var importedAt: Date
  public var sourceUserVersion: Int?
  public var sourceSize: Int64?
  public var sourceModifiedAt: Date?
  /// コピーした付属ファイル(`-journal` など)。
  public var sourceSidecars: [String] = []
  public var counts: Counts?
}

/// 引き継ぎの失敗。どれも元ファイルには触れておらず、次の起動でやり直せる。
public enum DatabaseImportError: Error, Equatable, Sendable {
  /// 元ファイルを一時フォルダへコピーできなかった。
  case copyFailed(String)
  /// コピーを SQLite として開けなかった(壊れている・DB ではない)。
  case openFailed(String)
  /// `quick_check` が ok を返さなかった。
  case integrityCheckFailed(String)
  /// スキーマの更新の前後で単語の数が変わった。
  case wordCountChanged(before: Int, after: Int)
  /// WAL に切り替えられなかった(返ってきたジャーナルモード)。
  case walUnavailable(String)
  /// 閉じた後も付属ファイルが残っていた。本体だけを移すと書き込みを失う。
  case sidecarsRemain([String])
  /// 本来の場所へ移せなかった。
  case moveFailed(String)
}
