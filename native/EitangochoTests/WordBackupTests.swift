import EitangochoData
import EitangochoSync
import Foundation
import Testing

@testable import Eitangocho

/// 書き出し / 読み込みのファイルの扱い(Flutter 版の word_backup_actions.dart。Flutter 版にテストは無く、
/// 変換そのものは EitangochoCore の WordExportServiceTests で確かめている)と、同期の状態の文言。
@MainActor
struct WordBackupTests {
  private let database: AppDatabase
  private let directory: URL

  init() throws {
    database = try AppDatabase.inMemory()
    directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
  }

  private func file(_ contents: Data) throws -> URL {
    let url = directory.appending(path: "backup.json")
    try contents.write(to: url)
    return url
  }

  @Test func 既定のファイル名は端末の日付() throws {
    let date = Date(timeIntervalSince1970: 1_790_000_000)  // 2026-09-21 14:13:20 UTC
    let utc = try #require(TimeZone(identifier: "UTC"))
    let kiritimati = try #require(TimeZone(identifier: "Pacific/Kiritimati"))  // UTC+14
    #expect(WordBackup.suggestedFileName(now: date, timeZone: utc) == "eitangocho-2026-09-21")
    #expect(WordBackup.suggestedFileName(now: date, timeZone: kiritimati) == "eitangocho-2026-09-22")
  }

  @Test func 書き出したファイルを読み込むと単語が戻る() async throws {
    _ = try await database.wordDao.insertWord(NewWord(word: "apple", meaning: "りんご"))
    let document = try #require(await WordBackup.makeDocument(WordExportService(database: database)))
    let url = try file(Data(document.json.utf8))

    let other = try AppDatabase.inMemory()
    let outcome = await WordBackup.importFile(at: url, into: WordExportService(database: other))

    #expect(outcome == .imported(ImportResult(added: 1)))
    #expect(try await other.wordDao.getAll().map(\.word) == ["apple"])
  }

  @Test func JSONでないファイルは形式の誤りになる() async throws {
    let service = WordExportService(database: database)
    #expect(await WordBackup.importFile(at: try file(Data("not json".utf8)), into: service) == .formatError(.invalidJson))
    #expect(await WordBackup.importFile(at: try file(Data([0xFF, 0xFE, 0x00])), into: service) == .formatError(.invalidJson))
  }

  @Test func 読めないファイルは失敗になる() async {
    let missing = directory.appending(path: "missing.json")
    #expect(await WordBackup.importFile(at: missing, into: WordExportService(database: database)) == .failed)
  }

  // MARK: - 同期の状態の文言(sync_status_text.dart)

  @Test func 最終同期の日時は秒を出さない() throws {
    let date = Date(timeIntervalSince1970: 1_785_188_700)  // 2026-07-27 21:45:00 UTC
    #expect(SyncStatusText.format(date, timeZone: try #require(TimeZone(identifier: "UTC"))) == "2026/07/27 21:45")
  }

  @Test func 同期中とまだ同期していないときの文言() {
    #expect(SyncStatusText.status(syncing: true, lastSyncedAt: .now) == String(localized: .syncing))
    #expect(SyncStatusText.status(syncing: false, lastSyncedAt: nil) == String(localized: .neverSynced))
  }
}
