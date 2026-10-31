import CryptoKit
import Foundation
import GRDB
import Testing

@testable import EitangochoData

/// Flutter 版の DB を App Group へ引き継ぐ処理のテスト。
/// 一時ディレクトリに「Flutter 版の Documents」と「App Group」を作って確かめる。
///
/// 中断の通知(AppDatabase.setSuspended)はプロセス内の `open` で開いた DB すべてに届くので、
/// このスイートの中は並べて走らせない(`open` を使うのはこのスイートだけ)。
@Suite(.serialized)
final class DriftDatabaseImporterTests {
  let root: URL
  let defaults: UserDefaults
  let suiteName = "DriftDatabaseImporterTests-\(UUID().uuidString)"

  var source: URL { root.appendingPathComponent("Documents/eitangocho.sqlite") }
  var destination: URL { root.appendingPathComponent("Group/Database/eitangocho.sqlite") }
  var importer: DriftDatabaseImporter {
    DriftDatabaseImporter(locations: .init(source: source, destination: destination), defaults: defaults)
  }

  init() throws {
    root = FileManager.default.temporaryDirectory.appendingPathComponent("importer-\(UUID().uuidString)")
    try FileManager.default.createDirectory(
      at: root.appendingPathComponent("Documents"), withIntermediateDirectories: true)
    defaults = UserDefaults(suiteName: suiteName)!
  }

  deinit {
    try? FileManager.default.removeItem(at: root)
    UserDefaults.standard.removePersistentDomain(forName: suiteName)
  }

  /// Flutter 版が作ったのと同じ形の DB を元の場所に作る(ジャーナルは drift の既定の DELETE)。
  private func makeSource(_ build: (Database) throws -> Void) throws {
    let queue = try DatabaseQueue(path: source.path)
    try queue.writeWithoutTransaction { db in try build(db) }
    try queue.close()
  }

  private func sha256(_ url: URL) throws -> String {
    SHA256.hash(data: try Data(contentsOf: url)).map { String(format: "%02x", $0) }.joined()
  }

  private func openDestination() throws -> AppDatabase {
    try AppDatabase.open(at: destination)
  }

  private func filesInDatabaseDirectory() throws -> [String] {
    try FileManager.default.contentsOfDirectory(atPath: destination.deletingLastPathComponent().path).sorted()
  }

  @Test("開いた DB は中断の通知で書き込みを止め、再開の通知で戻す(iOS の 0xdead10cc 対策)")
  func suspendsWritesWhileSuspended() async throws {
    _ = try importer.run()
    let database = try openDestination()
    defer { AppDatabase.setSuspended(false) }

    AppDatabase.setSuspended(true)
    await #expect(throws: DatabaseError.self) {
      try await database.wordDao.insertWord(NewWord(word: "apple", meaning: "りんご"))
    }
    AppDatabase.setSuspended(false)
    try await database.wordDao.insertWord(NewWord(word: "apple", meaning: "りんご"))
    #expect(try await database.wordDao.countWords() == 1)
  }

  @Test("元の DB が無ければ新規インストールとして始め、ファイルは作らない")
  func freshInstall() throws {
    let outcome = try importer.run()

    guard case .performed(let record) = outcome else { Issue.record("\(outcome)"); return }
    #expect(record.kind == .freshInstall)
    #expect(!FileManager.default.fileExists(atPath: destination.path))
    #expect(importer.record?.kind == .freshInstall)

    // 開けば最新のスキーマで作られる。
    let database = try openDestination()
    #expect(try database.writer.read { try AppDatabase.userVersion($0) } == 7)
  }

  @Test("v7 の DB を引き継ぐと単語・削除ログ・辞書がそろい、記録が残る")
  func importsV7() async throws {
    try makeSource { db in
      try DriftSchemaFixtures.createV4(db, userVersion: 7)
      try DriftSchemaFixtures.insertApple(db)
      try db.execute(sql: "INSERT INTO deleted_words (word, deleted_at) VALUES ('banana', 100)")
      try db.execute(sql: "INSERT INTO ejdict_entries (word, meanings) VALUES ('apple', 'リンゴ')")
    }

    let outcome = try importer.run()

    guard case .performed(let record) = outcome else { Issue.record("\(outcome)"); return }
    #expect(record.kind == .imported)
    #expect(record.sourceUserVersion == 7)
    #expect(record.counts == .init(words: 1, deletions: 1, ejdict: 1, dictionaryCache: 0))
    #expect(importer.record == record)

    let database = try openDestination()
    #expect(try await database.wordDao.getAll().map(\.word) == ["apple"])
    #expect(try await database.wordDao.getDeletions().map(\.word) == ["banana"])
    #expect(try await database.ejdictDao.lookup("apple") == "リンゴ")
  }

  @Test("引き継いだ DB は WAL で、一時フォルダは残らない")
  func leavesOnlyTheDatabase() throws {
    try makeSource { db in try DriftSchemaFixtures.createV4(db, userVersion: 7) }

    _ = try importer.run()

    #expect(try filesInDatabaseDirectory() == ["eitangocho.sqlite"])
    let mode = try DatabaseQueue(path: destination.path).read { db in
      try String.fetchOne(db, sql: "PRAGMA journal_mode")
    }
    #expect(mode == "wal")
  }

  @Test("古い版(v1・v3)の DB は v7 に上げてから引き継ぐ", arguments: [1, 3])
  func upgradesOldVersions(version: Int) async throws {
    try makeSource { db in
      if version == 1 {
        try DriftSchemaFixtures.createV1(db)
      } else {
        try DriftSchemaFixtures.createV2(db)
        try db.execute(sql: "PRAGMA user_version = 3")
      }
      try DriftSchemaFixtures.insertApple(db)
      try DriftSchemaFixtures.insertAppleCache(db)
    }

    let outcome = try importer.run()

    guard case .performed(let record) = outcome else { Issue.record("\(outcome)"); return }
    #expect(record.sourceUserVersion == version)
    let database = try openDestination()
    #expect(try await database.writer.read { try AppDatabase.userVersion($0) } == 7)
    #expect(try await database.wordDao.getAll().first?.translationLanguage == "ja")
    #expect(try await database.dictionaryCacheDao.find("apple") == nil)
  }

  @Test("元ファイルは付属ファイルも含めてバイト単位で変わらない")
  func leavesSourceUntouched() throws {
    try makeSource { db in
      try DriftSchemaFixtures.createV2(db)
      try db.execute(sql: "PRAGMA user_version = 3")
      try DriftSchemaFixtures.insertApple(db)
    }
    let before = try sha256(source)

    _ = try importer.run()

    #expect(try sha256(source) == before)
    // スキーマの更新(v3 → v7)も元ファイルには及んでいない。
    let version = try DatabaseQueue(path: source.path, configuration: readOnly).read {
      try AppDatabase.userVersion($0)
    }
    #expect(version == 3)
  }

  private var readOnly: Configuration {
    var configuration = Configuration()
    configuration.readonly = true
    return configuration
  }

  /// 書き込みの途中で落ちた状態を元の場所に作る: 未確定のトランザクションでページを
  /// 本体へ書き出させ(キャッシュを小さくして溢れさせる)、その瞬間の本体と
  /// ジャーナルを元の場所に複製する。
  private func simulateCrashedWrite() throws {
    let crashed = root.appendingPathComponent("crashed.sqlite")
    try FileManager.default.copyItem(at: source, to: crashed)
    let queue = try DatabaseQueue(path: crashed.path)
    try queue.writeWithoutTransaction { db in
      try db.execute(sql: "PRAGMA cache_size = 1")
      try db.execute(sql: "BEGIN")
      for i in 0..<500 {
        try db.execute(
          sql: "INSERT INTO words (word, japanese, created_at, updated_at) VALUES (?, ?, 0, 0)",
          arguments: ["word\(i)", String(repeating: "訳", count: 500)])
      }
      #expect(FileManager.default.fileExists(atPath: crashed.path + "-journal"))
      try FileManager.default.removeItem(at: source)
      try FileManager.default.copyItem(at: crashed, to: source)
      try FileManager.default.copyItem(
        at: URL(fileURLWithPath: crashed.path + "-journal"),
        to: URL(fileURLWithPath: source.path + "-journal"))
      try db.execute(sql: "ROLLBACK")
    }
  }

  @Test("ホットジャーナルが残った元ファイルは、コピーの方で巻き戻して引き継ぐ")
  func rollsBackHotJournalOnCopy() async throws {
    try makeSource { db in
      try DriftSchemaFixtures.createV4(db, userVersion: 7)
      try DriftSchemaFixtures.insertApple(db)
    }
    try simulateCrashedWrite()
    let sourceHash = try sha256(source)
    let journalHash = try sha256(URL(fileURLWithPath: source.path + "-journal"))

    let outcome = try importer.run()

    guard case .performed(let record) = outcome else { Issue.record("\(outcome)"); return }
    #expect(record.sourceSidecars == ["-journal"])
    // 未確定の 500 件は巻き戻り、確定していた 1 件だけが残る。
    let database = try openDestination()
    #expect(try await database.wordDao.getAll().map(\.word) == ["apple"])
    // 元ファイルとジャーナルはそのまま。
    #expect(try sha256(source) == sourceHash)
    #expect(try sha256(URL(fileURLWithPath: source.path + "-journal")) == journalHash)
  }

  @Test("壊れた元ファイルは失敗にし、印も空の DB も作らない")
  func rejectsCorruptedSource() throws {
    try Data(repeating: 0x42, count: 8192).write(to: source)

    let importer = importer
    #expect(throws: DatabaseImportError.self) { try importer.run() }

    #expect(!FileManager.default.fileExists(atPath: destination.path))
    #expect(importer.record == nil)
    #expect(try filesInDatabaseDirectory().isEmpty)
  }

  @Test("表はあるのに words が無い元ファイル(drift の DB ではない)は失敗にし、空の DB を作らない")
  func rejectsSourceWithoutWordsTable() throws {
    try makeSource { db in
      try db.execute(sql: "CREATE TABLE other (id INTEGER)")
      try db.execute(sql: "PRAGMA user_version = 7")
    }

    let importer = importer
    #expect(throws: DatabaseImportError.schemaMissing(userVersion: 7)) { try importer.run() }

    #expect(!FileManager.default.fileExists(atPath: destination.path))
    #expect(importer.record == nil)
  }

  @Test("中身の無い元ファイル(0 バイト)は、取り出せるデータが無いので空のまま引き継ぐ")
  func importsEmptySourceAsEmpty() async throws {
    try Data().write(to: source)

    guard case .performed(let record) = try importer.run() else { Issue.record(); return }

    #expect(record.kind == .imported)
    #expect(record.sourceSize == 0)
    #expect(record.counts?.words == 0)
    #expect(try await openDestination().wordDao.countWords() == 0)
  }

  @Test("引き継いだ DB が 0 バイトになっていたら、開かずに失敗にする")
  func rejectsEmptiedDestination() throws {
    try makeSource { db in
      try DriftSchemaFixtures.createV4(db, userVersion: 7)
      try DriftSchemaFixtures.insertApple(db)
    }
    _ = try importer.run()
    try Data().write(to: destination)

    let importer = importer
    #expect(throws: DatabaseImportError.destinationEmpty) { try importer.run() }
    // 元ファイルから引き継ぎ直せば戻る。
    guard case .performed = try importer.reimport() else { Issue.record(); return }
  }

  @Test("新規インストールの DB は 0 バイトでもそのまま開く(中身が -wal にしか無いことがある)")
  func acceptsEmptyFreshInstallDestination() throws {
    _ = try importer.run()
    try FileManager.default.createDirectory(
      at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
    try Data().write(to: destination)

    guard case .alreadyImported(let record) = try importer.run() else { Issue.record(); return }
    #expect(record?.kind == .freshInstall)
  }

  @Test("引き継ぎ済みなら元ファイルを読み直さない")
  func skipsWhenAlreadyImported() throws {
    try makeSource { db in
      try DriftSchemaFixtures.createV4(db, userVersion: 7)
      try DriftSchemaFixtures.insertApple(db)
    }
    guard case .performed(let first) = try importer.run() else { Issue.record(); return }

    var moved = false
    var second = importer
    second.moveItem = { _, _ in moved = true }
    let outcome = try second.run()

    #expect(outcome == .alreadyImported(first))
    #expect(!moved)
  }

  @Test("移す時点で一時フォルダに -wal / -shm / -journal が無い")
  func movesWithoutSidecars() throws {
    try makeSource { db in
      try DriftSchemaFixtures.createV4(db, userVersion: 7)
      try DriftSchemaFixtures.insertApple(db)
    }
    var checked: [String]?
    var importer = importer
    importer.moveItem = { from, to in
      checked = DriftDatabaseImporter.sidecarSuffixes.filter {
        FileManager.default.fileExists(atPath: from.path + $0)
      }
      try FileManager.default.moveItem(at: from, to: to)
    }

    _ = try importer.run()

    #expect(checked == [])
  }

  @Test("閉じた後に -wal が残っていたら移さずに失敗し、印も書かない")
  func refusesToMoveWithLeftoverWal() throws {
    try makeSource { db in
      try DriftSchemaFixtures.createV4(db, userVersion: 7)
      try DriftSchemaFixtures.insertApple(db)
    }
    var moved = false
    var importer = importer
    importer.afterClose = { copy in
      try Data("leftover".utf8).write(to: URL(fileURLWithPath: copy.path + "-wal"))
    }
    importer.moveItem = { _, _ in moved = true }

    #expect(throws: DatabaseImportError.sidecarsRemain(["-wal"])) { try importer.run() }

    #expect(!moved)
    #expect(importer.record == nil)
    #expect(!FileManager.default.fileExists(atPath: destination.path))
  }

  @Test("前回落ちた引き継ぎの一時フォルダは片付けてからやり直す")
  func cleansUpLeftoverWorkDirectory() throws {
    try makeSource { db in try DriftSchemaFixtures.createV4(db, userVersion: 7) }
    let leftover = destination.deletingLastPathComponent().appendingPathComponent("import-OLD")
    try FileManager.default.createDirectory(at: leftover, withIntermediateDirectories: true)

    _ = try importer.run()

    #expect(try filesInDatabaseDirectory() == ["eitangocho.sqlite"])
  }

  @Test("引き継ぎ直すと壊れたファイルを別名で残し、元ファイルから作り直す")
  func reimportKeepsBrokenFile() async throws {
    try makeSource { db in
      try DriftSchemaFixtures.createV4(db, userVersion: 7)
      try DriftSchemaFixtures.insertApple(db)
    }
    _ = try importer.run()
    try Data(repeating: 0x42, count: 8192).write(to: destination)

    let outcome = try importer.reimport(now: Date(timeIntervalSince1970: 1_700_000_000))

    guard case .performed(let record) = outcome else { Issue.record("\(outcome)"); return }
    #expect(record.kind == .imported)
    #expect(try filesInDatabaseDirectory() == ["eitangocho.sqlite", "eitangocho.sqlite.broken-1700000000"])
    #expect(try await openDestination().wordDao.getAll().map(\.word) == ["apple"])
  }
}
