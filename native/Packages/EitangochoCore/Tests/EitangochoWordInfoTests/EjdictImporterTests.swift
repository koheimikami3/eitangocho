import EitangochoData
import Foundation
import Testing

@testable import EitangochoWordInfo

/// Flutter 版の test/features/word_registration/data/ejdict_importer_test.dart の移植。
struct EjdictImporterTests {
  @Test("タブ区切りの行をパースする")
  func parsesTabSeparatedLines() {
    let entries = EjdictImporter.parse("apple\tリンゴ\nbook\t本 / 書物")
    #expect(entries.map(\.word) == ["apple", "book"])
    #expect(entries.map(\.meanings) == ["リンゴ", "本 / 書物"])
  }

  @Test("タブで 2 分割できない行はスキップする")
  func skipsLinesWithoutTab() {
    let entries = EjdictImporter.parse("apple\tリンゴ\n\nタブなし行\n\tタブ先頭\nempty\t\n")
    #expect(entries.map(\.word) == ["apple"])
  }

  @Test("同一単語の複数行は訳を改行で連結して 1 レコードにする")
  func mergesDuplicates() {
    let entries = EjdictImporter.parse("coup\t不意の一撃\nbook\t本\ncoup\t=coup d'état")
    #expect(entries.count == 2)
    #expect(entries.first { $0.word == "coup" }?.meanings == "不意の一撃\n=coup d'état")
  }

  @Test("取込済み(count > 0)ならファイルを読まず 0 を返す")
  func skipsWhenImported() async throws {
    let database = try AppDatabase.inMemory()
    try await database.ejdictDao.bulkInsert([("apple", "リンゴ")])

    // 存在しないファイルを渡す。読みに行けば失敗するので、0 が返る = 件数で判定してスキップした。
    let imported = try await EjdictImporter.importIfNeeded(
      dao: database.ejdictDao, source: URL(fileURLWithPath: "/nonexistent/ejdict.txt"))

    #expect(imported == 0)
    #expect(try await database.ejdictDao.count() == 1)
  }

  @Test("未取込ならファイルを読んで取り込む")
  func importsFromFile() async throws {
    let database = try AppDatabase.inMemory()
    let url = FileManager.default.temporaryDirectory.appendingPathComponent("ejdict-\(UUID().uuidString).txt")
    try "apple\tリンゴ\nbook\t本\n".write(to: url, atomically: true, encoding: .utf8)
    defer { try? FileManager.default.removeItem(at: url) }

    #expect(try await EjdictImporter.importIfNeeded(dao: database.ejdictDao, source: url) == 2)
    #expect(try await database.ejdictDao.lookup("book") == "本")
  }
}
