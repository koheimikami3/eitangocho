import EitangochoData
import Foundation
import Testing

@testable import EitangochoSync

/// Flutter 版の test/features/settings/data/word_export_service_test.dart の移植と、
/// Flutter 版と読み書きし合えることの確認。
struct WordExportServiceTests {
  let database: AppDatabase
  let service: WordExportService
  var dao: WordDao { database.wordDao }

  init() throws {
    database = try AppDatabase.inMemory()
    service = WordExportService(database: database)
  }

  /// 日付の基準(2026-01-01T00:00:00Z)。DB は秒精度なので秒単位の日時を使う。
  static let base = Date(timeIntervalSince1970: 1_767_225_600)

  static func day(_ days: Double) -> Date { base.addingTimeInterval(days * 86_400) }

  private func object(_ json: String) throws -> [String: Any] {
    try #require(try JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: Any])
  }

  @discardableResult
  private func insert(_ word: String, meaning: String = "訳", updatedAt: Date = base) async throws -> Int64 {
    try await dao.insertWord(NewWord(word: word, meaning: meaning), now: updatedAt)
  }

  // MARK: - 往復・上書き

  @Test("書き出した JSON を取り込むと内容が一致する(往復)")
  func roundTrip() async throws {
    try await dao.insertWord(
      NewWord(
        word: "serendipity", meaning: "偶然の幸運", ipa: "/ˌserənˈdɪpəti/", partsOfSpeech: [.noun],
        exampleEn: "Meeting her was pure serendipity.", exampleTranslation: "彼女に出会えたのはまったくの偶然の幸運だった。"))

    let json = try await service.exportJson()
    let decoded = try object(json)
    #expect(decoded["version"] as? Int == 2)
    #expect(decoded["exportedAt"] is String)
    let words = try #require(decoded["words"] as? [[String: Any]])
    #expect(words.count == 1)
    #expect(words.first?["id"] == nil)

    try await dao.deleteWord(id: try #require(try await dao.getAll().first).id)
    #expect(try await dao.getAll().isEmpty)

    let result = try await service.importJson(json)
    #expect(result == ImportResult(added: 1))

    let imported = try #require(try await dao.getAll().first)
    #expect(imported.word == "serendipity")
    #expect(imported.meaning == "偶然の幸運")
    #expect(imported.ipa == "/ˌserənˈdɪpəti/")
    #expect(imported.partsOfSpeech == [.noun])
    #expect(imported.exampleEn == "Meeting her was pure serendipity.")
  }

  @Test("ファイル側の updatedAt が新しければ上書きされる")
  func newerFileWins() async throws {
    let id = try await insert("apple", meaning: "りんご")

    let result = try await service.importJson(v1([entry("apple", "リンゴ", updatedAt: Self.day(1))]))

    #expect(result.added == 0)
    #expect(result.updated == 1)
    #expect(result.unchanged == 0)
    let after = try await dao.getAll()
    #expect(after.count == 1)
    #expect(after.first?.id == id)
    #expect(after.first?.meaning == "リンゴ")
    // word の表記と createdAt は DB 側を保つ。
    #expect(after.first?.word == "apple")
    #expect(after.first?.createdAt == Self.base)
  }

  @Test("ファイル側の updatedAt が古い・同時刻なら上書きされない(変更なし)", arguments: [-1.0, 0.0])
  func olderOrSameFileLoses(offsetDays: Double) async throws {
    let id = try await insert("apple", meaning: "りんご")

    let result = try await service.importJson(v1([entry("apple", "リンゴ", updatedAt: Self.day(offsetDays))]))

    #expect(result.updated == 0)
    #expect(result.unchanged == 1)
    let after = try #require(try await dao.getAll().first)
    #expect(after.id == id)
    #expect(after.meaning == "りんご")
  }

  @Test("単語の照合は trim + 小文字化で行い、DB 側の表記を保つ")
  func matchesByNormalizedKey() async throws {
    try await insert("apple", meaning: "りんご")

    let result = try await service.importJson(v1([entry(" Apple ", "リンゴ", updatedAt: Self.day(1))]))

    #expect(result.updated == 1)
    let after = try await dao.getAll()
    #expect(after.count == 1)
    #expect(after.first?.word == "apple")
    #expect(after.first?.meaning == "リンゴ")
  }

  // MARK: - 壊れた入力

  @Test("word・japanese の欠落や型の不正・空文字の行は飛ばして続ける")
  func skipsInvalidRows() async throws {
    let json = """
      {"version": 1, "exportedAt": "2026-01-01T00:00:00.000Z", "words": [
        {"japanese": "訳のみ"},
        {"word": "no-japanese"},
        {"word": 123, "japanese": "型不正"},
        {"word": "  ", "japanese": "空白のみ"},
        "not a map",
        {"word": "bad-learned", "japanese": "型不正", "isLearned": 1},
        {"word": "bad-date", "japanese": "日時不正", "updatedAt": "yesterday"},
        {"word": "bad-pos", "japanese": "品詞不正", "partsOfSpeech": ["noun", 1]},
        {"word": "valid", "japanese": "有効"}
      ]}
      """

    let result = try await service.importJson(json)

    #expect(result.skipped == 8)
    #expect(result.added == 1)
    #expect(try await dao.getAll().map(\.word) == ["valid"])
  }

  @Test("未知の version は失敗にして中断する", arguments: [#"99"#, #""2""#, #"true"#])
  func rejectsUnknownVersion(version: String) async throws {
    let json = #"{"version": \#(version), "exportedAt": "2026-01-01T00:00:00Z", "words": []}"#

    await #expect(throws: WordExportFormatError.unsupportedVersion) {
      try await service.importJson(json)
    }
  }

  @Test("壊れた JSON は失敗にする")
  func rejectsBrokenJson() async throws {
    await #expect(throws: WordExportFormatError.invalidJson) {
      try await service.importJson("{not valid json")
    }
  }

  @Test("トップレベルや words の型が違えば失敗にする", arguments: [#"[]"#, #"{"version": 1, "words": {}}"#])
  func rejectsInvalidFormat(json: String) async throws {
    await #expect(throws: WordExportFormatError.invalidFormat) {
      try await service.importJson(json)
    }
  }

  // MARK: - 項目ごとの既定値

  @Test("translationLanguage の無い行は日本語として取り込み、ある行はそのまま持ち回す")
  func translationLanguageDefaultsToJa() async throws {
    let json = """
      {"version": 1, "exportedAt": "2026-01-01T00:00:00Z", "words": [
        {"word": "apple", "japanese": "りんご"},
        {"word": "achieve", "japanese": "實現", "translationLanguage": "zh-Hant"},
        {"word": "future", "japanese": "?", "translationLanguage": "ko"}
      ]}
      """

    try await service.importJson(json)

    let byWord = Dictionary(uniqueKeysWithValues: try await dao.getAll().map { ($0.word, $0.translationLanguage) })
    #expect(byWord == ["apple": "ja", "achieve": "zh-Hant", "future": "ko"])

    // 書き出しにも載り、JSON のキーは訳の言語によらず japanese のまま。
    let exported = try #require(try object(try await service.exportJson())["words"] as? [[String: Any]])
    let achieve = try #require(exported.first { $0["word"] as? String == "achieve" })
    #expect(achieve["japanese"] as? String == "實現")
    #expect(achieve["translationLanguage"] as? String == "zh-Hant")
  }

  @Test("未知の partsOfSpeech 名は捨てて既知の値だけ復元する")
  func dropsUnknownPartsOfSpeech() async throws {
    let json = """
      {"version": 1, "exportedAt": "2026-01-01T00:00:00Z", "words": [
        {"word": "apple", "japanese": "りんご", "partsOfSpeech": ["noun", "unknownPos"]}
      ]}
      """

    let result = try await service.importJson(json)

    #expect(result.added == 1)
    #expect(try await dao.getAll().first?.partsOfSpeech == [.noun])
  }

  @Test("ファイル内に同一単語が複数あれば updatedAt が新しい方だけ採用する")
  func keepsNewestDuplicateInFile() async throws {
    let result = try await service.importJson(
      v1([entry("apple", "古い訳", updatedAt: Self.day(0)), entry("apple", "新しい訳", updatedAt: Self.day(1))]))

    #expect(result.added == 1)
    #expect(result.unchanged == 1)
    let words = try await dao.getAll()
    #expect(words.count == 1)
    #expect(words.first?.meaning == "新しい訳")
  }

  // MARK: - lastReviewedAt

  /// apple を登録し、lastReviewedAt を入れた既存行を返す。
  private func seedApple(reviewedAt: Date?) async throws -> Word {
    let id = try await insert("apple", meaning: "りんご")
    if let reviewedAt { try await dao.recordQuizResult(id: id, knew: false, now: reviewedAt) }
    return try #require(try await dao.getAll().first)
  }

  @Test("内容が古いファイルでも、新しい lastReviewedAt だけは取り込む")
  func takesNewerLastReviewedAt() async throws {
    let existing = try await seedApple(reviewedAt: Self.day(10))

    let result = try await service.importJson(
      v1([entry("apple", "リンゴ", updatedAt: Self.day(-1), lastReviewedAt: Self.day(11))]))

    // 内容は変えていないので「変更なし」に数える。
    #expect(result.updated == 0)
    #expect(result.unchanged == 1)
    let after = try #require(try await dao.getAll().first)
    #expect(after.lastReviewedAt == Self.day(11))
    #expect(after.meaning == "りんご")
    #expect(after.updatedAt == existing.updatedAt)
  }

  @Test("未回答の単語にもファイル側の lastReviewedAt を取り込む")
  func takesLastReviewedAtForUnanswered() async throws {
    let existing = try await seedApple(reviewedAt: nil)

    try await service.importJson(
      v1([entry("apple", "りんご", updatedAt: existing.updatedAt, lastReviewedAt: Self.day(10))]))

    #expect(try await dao.getAll().first?.lastReviewedAt == Self.day(10))
  }

  @Test("ファイル側の lastReviewedAt が古ければ書き換えない")
  func keepsNewerLocalLastReviewedAt() async throws {
    _ = try await seedApple(reviewedAt: Self.day(11))

    try await service.importJson(
      v1([entry("apple", "りんご", updatedAt: Self.day(-1), lastReviewedAt: Self.day(10))]))

    #expect(try await dao.getAll().first?.lastReviewedAt == Self.day(11))
  }

  @Test("内容がファイル側の勝ちでも、lastReviewedAt は古くしない")
  func neverRewindsLastReviewedAt() async throws {
    _ = try await seedApple(reviewedAt: Self.day(11))

    let result = try await service.importJson(
      v1([entry("apple", "リンゴ", updatedAt: Self.day(1), lastReviewedAt: Self.day(10))]))

    #expect(result.updated == 1)
    let after = try #require(try await dao.getAll().first)
    #expect(after.meaning == "リンゴ")
    #expect(after.lastReviewedAt == Self.day(11))
  }

  // MARK: - 削除ログ

  @Test("ローカルの単語より新しい削除ログはその単語を消す")
  func newerTombstoneDeletes() async throws {
    try await insert("apple", updatedAt: Self.day(0))

    let result = try await service.importJson(v2(words: [], deletions: [deletion("apple", Self.day(31))]))

    #expect(result.deleted == 1)
    #expect(try await dao.getAll().isEmpty)
  }

  @Test("削除と同時刻の編集は削除の勝ち")
  func tieGoesToDeletion() async throws {
    try await insert("apple", updatedAt: Self.day(0))

    let result = try await service.importJson(v2(words: [], deletions: [deletion("apple", Self.day(0))]))

    #expect(result.deleted == 1)
  }

  @Test("削除ログより後にローカルで編集していれば消さない")
  func laterLocalEditSurvives() async throws {
    try await insert("apple", updatedAt: Self.day(59))

    let result = try await service.importJson(v2(words: [], deletions: [deletion("apple", Self.day(31))]))

    #expect(result.deleted == 0)
    #expect(try await dao.getAll().count == 1)
  }

  @Test("ローカルに無い単語の削除ログもログとして取り込む(第 3 の端末へ伝える)")
  func keepsTombstoneWithoutLocalWord() async throws {
    try await service.importJson(v2(words: [], deletions: [deletion("apple", Self.day(31))]))

    #expect(try await dao.getDeletions() == [DeletedWord(word: "apple", deletedAt: Self.day(31))])
  }

  @Test("削除より新しい単語がファイルに載っていれば復活させ、ログは取り消す")
  func newerFileWordRevives() async throws {
    let result = try await service.importJson(
      v2(words: [entry("apple", "りんご", updatedAt: Self.day(59))], deletions: [deletion("apple", Self.day(31))]))

    #expect(result.added == 1)
    #expect(result.deleted == 0)
    #expect(try await dao.getAll().map(\.word) == ["apple"])
    #expect(try await dao.getDeletions().isEmpty)
  }

  @Test("ローカルの編集が削除より新しくても、ファイル側の再登録がさらに新しければ残す")
  func newestFileWordWins() async throws {
    try await insert("apple", updatedAt: Self.day(59))

    let result = try await service.importJson(
      v2(words: [entry("apple", "新しい訳", updatedAt: Self.day(90))], deletions: [deletion("apple", Self.day(31))]))

    #expect(result.updated == 1)
    #expect(result.deleted == 0)
    #expect(try await dao.getAll().first?.meaning == "新しい訳")
  }

  @Test("削除ログは大文字小文字・前後空白を無視して突き合わせる")
  func tombstoneMatchesNormalizedKey() async throws {
    try await insert("Apple", updatedAt: Self.day(0))

    let result = try await service.importJson(v2(words: [], deletions: [deletion("  APPLE ", Self.day(31))]))

    #expect(result.deleted == 1)
    #expect(try await dao.getAll().isEmpty)
  }

  @Test("壊れた削除ログの行は捨てて、単語本体の取り込みは続ける")
  func skipsBrokenTombstones() async throws {
    let json = """
      {"version": 2, "exportedAt": "2026-01-01T00:00:00Z",
       "words": [{"word": "apple", "japanese": "りんご", "updatedAt": "2026-01-01T00:00:00.000Z"}],
       "deletions": [{"word": "banana"}, "not a map", {"word": "cherry", "deletedAt": "not a date"}]}
      """

    let result = try await service.importJson(json)

    #expect(result.added == 1)
    #expect(try await dao.getDeletions().isEmpty)
  }

  @Test("同期では自分の削除ログを尊重し、手動の取り込みでは復元する")
  func respectsLocalDeletionsOnlyWhenSyncing() async throws {
    let id = try await insert("apple", updatedAt: Self.day(0))
    try await dao.deleteWord(id: id, now: Self.day(31))
    let snapshot = v1([entry("apple", "りんご", updatedAt: Self.day(0))])

    let synced = try await service.importJson(snapshot, respectLocalDeletions: true)
    #expect(synced.added == 0)
    #expect(try await dao.getAll().isEmpty)

    let restored = try await service.importJson(snapshot)
    #expect(restored.added == 1)
  }

  @Test("書き出しには削除ログが含まれる")
  func exportIncludesTombstones() async throws {
    let id = try await insert("apple", updatedAt: Self.day(0))
    try await dao.deleteWord(id: id, now: Self.day(1))

    let deletions = try #require(try object(try await service.exportJson())["deletions"] as? [[String: Any]])
    #expect(deletions.count == 1)
    #expect(deletions.first?["word"] as? String == "apple")
    #expect(deletions.first?["deletedAt"] as? String == "2026-01-02T00:00:00.000Z")
  }

  // MARK: - Flutter 版との互換

  @Test("Flutter 版が書き出したファイルを読める")
  func readsFlutterExport() async throws {
    let json = try fixture("flutter-export.json")

    let result = try await service.importJson(json)

    #expect(result == ImportResult(added: 2))
    let achieve = try #require(try await dao.findByWord("achieve"))
    #expect(achieve.meaning == "實現")
    #expect(achieve.ipa == "/əˈtʃiːv/")
    #expect(achieve.partsOfSpeech == [.verb])
    #expect(achieve.exampleTranslation == "她實現了目標。")
    #expect(achieve.translationLanguage == "zh-Hant")
    #expect(achieve.isLearned)
    #expect(achieve.lastReviewedAt == ExportDate.parse("2026-10-28T09:00:00Z"))
    #expect(achieve.correctCount == 3)
    #expect(achieve.createdAt == ExportDate.parse("2026-10-01T00:00:00Z"))
    #expect(achieve.updatedAt == ExportDate.parse("2026-10-02T12:30:15Z"))
    let phrase = try #require(try await dao.findByWord("run out of"))
    #expect(phrase.lastReviewedAt == nil)
    #expect(phrase.partsOfSpeech == [.verb, .other])
    #expect(try await dao.getDeletions().map(\.word) == ["apple"])
  }

  /// Swift 版が書き出したファイル。Flutter 版のテスト
  /// (test/features/settings/data/native_export_compat_test.dart)がこれを読めることを確かめる。
  /// 書き出しの形を変えたら、`UPDATE_FIXTURES=1 swift test` で作り直してから両方のテストを通す。
  @Test("Swift 版の書き出しは固定データ swift-export.json と一致する")
  func writesSwiftExportFixture() async throws {
    let fileJson = try fixture("flutter-export.json")
    try await service.importJson(fileJson, now: Self.base)

    let exported = try await service.exportJson(now: ExportDate.parse("2026-10-29T03:04:05.123Z")!)

    if ProcessInfo.processInfo.environment["UPDATE_FIXTURES"] == "1" {
      let url = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        .appendingPathComponent("Fixtures/swift-export.json")
      try (exported + "\n").write(to: url, atomically: true, encoding: .utf8)
    }
    #expect(exported + "\n" == (try fixture("swift-export.json")))
  }

  // MARK: - 日時の読み書き

  @Test("日時は Dart の toIso8601String と同じ形で書く")
  func formatsLikeDart() {
    #expect(ExportDate.format(Date(timeIntervalSince1970: 0)) == "1970-01-01T00:00:00.000Z")
    #expect(ExportDate.format(Self.base.addingTimeInterval(0.25)) == "2026-01-01T00:00:00.250Z")
  }

  @Test(
    "Dart の DateTime.parse が読む形を読める",
    arguments: [
      ("2026-01-01T00:00:00.000Z", 0.0),
      ("2026-01-01T00:00:00Z", 0.0),
      ("2026-01-01T00:00:00.123456Z", 0.123456),
      ("2026-01-01T00:00:00.1234567Z", 0.123456),
      ("2026-01-01T09:00:00+09:00", 0.0),
      ("2026-01-01T09:00:00+0900", 0.0),
      ("2025-12-31T19:00:00-05:00", 0.0),
      ("2026-01-01 00:00:00Z", 0.0),
      ("20260101T000000Z", 0.0),
    ])
  func parsesDartFormats(string: String, offset: Double) throws {
    let date = try #require(ExportDate.parse(string))
    #expect(abs(date.timeIntervalSince(Self.base) - offset) < 0.000_001)
  }

  @Test("時差の無い日時は端末の時刻として読む(Dart と同じ)")
  func parsesLocalTime() throws {
    let date = try #require(ExportDate.parse("2026-01-01T00:00:00"))
    let offset = TimeInterval(TimeZone.current.secondsFromGMT(for: date))
    #expect(date.timeIntervalSince(Self.base) == -offset)
  }

  @Test("日時でない文字列は読まない", arguments: ["", "yesterday", "2026/01/01", "2026-01-01T"])
  func rejectsNonDates(string: String) {
    #expect(ExportDate.parse(string) == nil)
  }

  // MARK: - ヘルパー

  private func fixture(_ name: String) throws -> String {
    let url = try #require(Bundle.module.url(forResource: "Fixtures/\(name)", withExtension: nil))
    return try String(contentsOf: url, encoding: .utf8)
  }

  /// version 1(deletions を持たない旧形式)。後方互換の確認を兼ねる。
  private func v1(_ words: [[String: Any]]) -> String {
    serialize(["version": 1, "exportedAt": "2026-01-01T00:00:00.000Z", "words": words])
  }

  private func v2(words: [[String: Any]], deletions: [[String: Any]]) -> String {
    serialize(["version": 2, "exportedAt": "2026-01-01T00:00:00.000Z", "words": words, "deletions": deletions])
  }

  private func serialize(_ object: [String: Any]) -> String {
    String(decoding: try! JSONSerialization.data(withJSONObject: object), as: UTF8.self)
  }

  private func deletion(_ word: String, _ deletedAt: Date) -> [String: Any] {
    ["word": word, "deletedAt": ExportDate.format(deletedAt)]
  }

  private func entry(_ word: String, _ meaning: String, updatedAt: Date, lastReviewedAt: Date? = nil)
    -> [String: Any]
  {
    var entry: [String: Any] = [
      "word": word, "japanese": meaning,
      "updatedAt": ExportDate.format(updatedAt), "createdAt": ExportDate.format(updatedAt),
    ]
    if let lastReviewedAt { entry["lastReviewedAt"] = ExportDate.format(lastReviewedAt) }
    return entry
  }
}
