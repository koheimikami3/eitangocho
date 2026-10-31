import EitangochoData
import Foundation

/// 書き出し・取り込みの JSON が不正なときの失敗
/// (未知の version・トップレベルの型の不正・JSON 自体の読み取り失敗)。
/// 文言は持たず、表示側が言語に合わせて出す。
public enum WordExportFormatError: Error, Equatable, Sendable {
  case invalidJson
  case invalidFormat
  case unsupportedVersion
}

/// 取り込みの結果の件数。
public struct ImportResult: Equatable, Sendable {
  public var added: Int
  public var updated: Int
  public var unchanged: Int
  public var skipped: Int
  /// ファイル側の削除ログにより消した単語の件数。
  public var deleted: Int

  public init(added: Int = 0, updated: Int = 0, unchanged: Int = 0, skipped: Int = 0, deleted: Int = 0) {
    self.added = added
    self.updated = updated
    self.unchanged = unchanged
    self.skipped = skipped
    self.deleted = deleted
  }
}

/// JSON の書き出し・取り込み(Flutter 版の WordExportService の移植)。
///
/// iCloud 同期のスナップショットと手動のバックアップは同じ形式で、Flutter 版と
/// 読み書きし合う。古い OS の端末は Flutter 版のまま同期し続けるので、
/// **形式のバージョンは上げず、必須のキーも足さない**(docs/design.md「データ・同期」)。
/// ファイルの選択・読み書きは呼び出し側の役目で、ここは文字列 ⇔ DB の変換だけを扱う。
public struct WordExportService: Sendable {
  /// 書き出す形式のバージョン。v1 = words のみ / v2 = deletions(削除ログ)を追加。
  static let currentVersion = 2

  /// 読み込みを受け付けるバージョン。v1 には deletions が無いので空として扱う。
  static let supportedVersions: Set<Int> = [1, 2]

  let database: AppDatabase

  public init(database: AppDatabase) {
    self.database = database
  }

  // MARK: - 書き出し

  public func exportJson(now: Date = .now) async throws -> String {
    let words = try await database.wordDao.getAll()
    let deletions = try await database.wordDao.getDeletions()
    let file = ExportFile(
      version: Self.currentVersion,
      exportedAt: now,
      words: words.map(ExportFile.Entry.init),
      deletions: deletions.map { .init(word: $0.word, deletedAt: $0.deletedAt) })
    let encoder = JSONEncoder()
    // キーの並びを固定する(並びに意味は無いが、同じ内容なら同じ文字列になるように)。
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    return String(decoding: try encoder.encode(file), as: UTF8.self)
  }

  // MARK: - 取り込み

  /// マージ方式で取り込む。
  /// - 単語は trim + 小文字化したキーで既存の行と突き合わせる
  /// - 一致なし: 追加(ファイルの createdAt / updatedAt を保つ)
  /// - 一致あり: ファイル側の updatedAt が新しいときだけ上書き(word の表記・
  ///   createdAt は DB 側を保つ)。それ以外は変更なし
  /// - クイズの回答の実績は単語の勝敗と切り離し、lastReviewedAt はファイルと DB の新しい方、
  ///   correctCount は大きい方を採る(手動の取り込みでも古いバックアップで回数を減らさない)
  /// - word / japanese の欠落・型の不正・空文字の行は飛ばして続ける
  /// - ファイル内に同じ単語が複数あれば、updatedAt が新しい方だけを採る
  /// - 削除ログは、同じキーの単語がローカルにあり deletedAt がその updatedAt より
  ///   新しければ消す。ローカルに無くてもログ自体は取り込む(第 3 の端末へ伝えるため)
  /// - 同じキーが words と deletions の両方にあれば、新しい方の操作を採る
  /// - 全体を 1 トランザクションで行う
  ///
  /// `respectLocalDeletions` はこちらの削除ログを尊重するかどうか。
  /// - 同期では true。自分が消した単語が、まだその削除を知らないクラウドの
  ///   スナップショットから復活するのを防ぐ
  /// - 手動の取り込み(バックアップの復元)では false。ファイルにある単語は、
  ///   後から消していても復元する
  public func importJson(_ source: String, respectLocalDeletions: Bool = false, now: Date = .now)
    async throws -> ImportResult
  {
    let decoded: Any
    do {
      decoded = try JSONSerialization.jsonObject(with: Data(source.utf8), options: [.fragmentsAllowed])
    } catch {
      throw WordExportFormatError.invalidJson
    }
    guard let root = decoded as? [String: Any] else { throw WordExportFormatError.invalidFormat }
    guard let version = JSONValue.integer(root["version"]), Self.supportedVersions.contains(version) else {
      throw WordExportFormatError.unsupportedVersion
    }
    guard let rawWords = root["words"] as? [Any] else { throw WordExportFormatError.invalidFormat }
    // v1 には deletions が無い。型が違う場合も欠落と同じく空として扱い、
    // 単語本体の取り込みまで巻き添えで失敗させない。
    let deletionsByKey = Self.parseDeletions(root["deletions"] as? [Any] ?? [])

    let dao = database.wordDao
    var existingByKey: [String: Word] = [:]
    for row in try await dao.getAll() {
      existingByKey[WordDao.matchKey(row.word)] = row
    }
    // こちらで削除済みの単語。ファイルにその単語が残っていても、削除の方が
    // 新しければ復活させない。
    var localDeletions: [String: Date] = [:]
    if respectLocalDeletions {
      for deletion in try await dao.getDeletions() {
        localDeletions[WordDao.matchKey(deletion.word)] = deletion.deletedAt
      }
    }

    var result = ImportResult()
    // ファイル内の重複を先に解決するための、キーごとの採用候補(最初に現れた順)。
    var planned = OrderedEntries<PlannedEntry>()
    for raw in rawWords {
      guard let entry = ExportFile.Entry(json: raw) else {
        result.skipped += 1
        continue
      }
      let word = entry.word.trimmingCharacters(in: .whitespacesAndNewlines)
      let meaning = entry.meaning.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !word.isEmpty, !meaning.isEmpty else {
        result.skipped += 1
        continue
      }
      let key = WordDao.matchKey(word)
      let updatedAt = entry.updatedAt ?? Date(timeIntervalSince1970: 0)
      if let existing = planned[key] {
        // 採用済みの候補と比べ、負けた方を「変更なし」に数える。
        result.unchanged += 1
        if updatedAt <= existing.updatedAt { continue }
      }
      planned[key] = PlannedEntry(
        word: word, meaning: meaning, entry: entry, updatedAt: updatedAt,
        createdAt: entry.createdAt ?? now)
    }

    var inserts: [ImportedWord] = []
    var updates: [(id: Int64, update: WordImportUpdate)] = []
    var quizProgressUpdates: [(id: Int64, update: WordImportUpdate)] = []
    for (key, plan) in planned.elements {
      // 同じ単語が words と deletions の両方に載っていることがある
      // (別端末で削除された後、さらに別の端末で再登録された場合など)。新しい方を採る。
      if let deletedAt = Self.later(deletionsByKey[key], localDeletions[key]),
        !Self.wordWins(updatedAt: plan.updatedAt, deletedAt: deletedAt)
      {
        continue
      }
      guard let existing = existingByKey[key] else {
        inserts.append(
          plan.imported(lastReviewedAt: plan.entry.lastReviewedAt, correctCount: plan.entry.correctCount))
        continue
      }
      // クイズの回答は updatedAt を動かさないため、回答の実績は単語の勝敗と切り離して
      // 両方を合わせた値にする(内容がこちらの勝ちでも、回答はファイル側が新しいことがある)。
      // - lastReviewedAt は新しい方(端末ごとに出題の一巡がずれないように)
      // - correctCount は大きい方。回数は増えるだけなので、大きい方がより多くの回答を含む。
      //   2 台で同じ頃に答えた分は片方の加算が失われうるが、何度同期しても結果が変わらない
      let lastReviewedAt = Self.later(plan.entry.lastReviewedAt, existing.lastReviewedAt)
      let correctCount = max(plan.entry.correctCount, existing.correctCount)
      if plan.updatedAt > existing.updatedAt {
        updates.append(
          (existing.id, .content(plan.imported(lastReviewedAt: lastReviewedAt, correctCount: correctCount))))
      } else {
        if lastReviewedAt != existing.lastReviewedAt || correctCount != existing.correctCount {
          quizProgressUpdates.append(
            (existing.id, .quizProgress(lastReviewedAt: lastReviewedAt, correctCount: correctCount)))
        }
        // 内容は変えていないので「変更なし」に数える。
        result.unchanged += 1
      }
    }

    // 削除ログの適用。削除の後にこちらで編集していれば、その編集が勝つ。
    var deleteIds: [Int64] = []
    for (key, deletedAt) in deletionsByKey.elements {
      guard let existing = existingByKey[key] else { continue }
      if Self.wordWins(updatedAt: existing.updatedAt, deletedAt: deletedAt) { continue }
      // ファイル側の words に、削除より新しい同じ単語が載っている場合
      // (削除 → 別端末で再登録・再編集)。上で採用済みなので、消すと打ち消してしまう。
      if let plan = planned[key], Self.wordWins(updatedAt: plan.updatedAt, deletedAt: deletedAt) {
        continue
      }
      deleteIds.append(existing.id)
    }

    try await dao.importWords(
      inserts: inserts,
      updates: updates + quizProgressUpdates,
      deleteIds: deleteIds,
      // ローカルに単語が無い分も含め、ログはすべて取り込む。
      deletions: deletionsByKey.elements.map { DeletedWord(word: $0.key, deletedAt: $0.value) })

    result.added = inserts.count
    result.updated = updates.count
    result.deleted = deleteIds.count
    return result
  }

  /// 単語の更新が削除に勝つか。
  ///
  /// 同時刻のときは削除を勝たせる。DB の日時は秒精度なので、「編集した直後に
  /// 同じ秒で削除した」場合に updatedAt と deletedAt が一致しうる。その並びでは
  /// 削除が後の操作なので、引き分けを削除の勝ちにしないと消した単語が復活する。
  static func wordWins(updatedAt: Date, deletedAt: Date) -> Bool {
    updatedAt > deletedAt
  }

  /// 2 つの日時のうち新しい方(nil は「無い」扱い)。
  static func later(_ a: Date?, _ b: Date?) -> Date? {
    guard let a else { return b }
    guard let b else { return a }
    return a > b ? a : b
  }

  /// 削除ログをキー → deletedAt に畳み込む。同じ単語が複数あれば新しい方を採る。
  /// 単語本体と同じく、不正な行は捨てて取り込み全体は続ける。
  static func parseDeletions(_ raw: [Any]) -> OrderedEntries<Date> {
    var result = OrderedEntries<Date>()
    for item in raw {
      guard let object = item as? [String: Any],
        let word = object["word"] as? String,
        let deletedAtString = object["deletedAt"] as? String,
        let deletedAt = ExportDate.parse(deletedAtString)
      else { continue }
      let key = WordDao.matchKey(word)
      if key.isEmpty { continue }
      if let existing = result[key], deletedAt <= existing { continue }
      result[key] = deletedAt
    }
    return result
  }
}

/// ファイル内で採用する候補。
private struct PlannedEntry {
  var word: String
  var meaning: String
  var entry: ExportFile.Entry
  var updatedAt: Date
  var createdAt: Date

  func imported(lastReviewedAt: Date?, correctCount: Int) -> ImportedWord {
    ImportedWord(
      word: word, meaning: meaning, ipa: entry.ipa,
      partsOfSpeech: entry.partsOfSpeech.compactMap(PartOfSpeech.init(rawValue:)),
      exampleEn: entry.exampleEn, exampleTranslation: entry.exampleTranslation,
      translationLanguage: entry.translationLanguage, audioUrl: entry.audioUrl,
      isLearned: entry.isLearned, lastReviewedAt: lastReviewedAt, correctCount: correctCount,
      createdAt: createdAt, updatedAt: updatedAt)
  }
}

/// 最初に入れた順を保つ辞書(Dart の Map と同じ並びで処理するため)。
/// 既にあるキーに入れ直しても、位置は最初のまま変えない。
struct OrderedEntries<Value> {
  private(set) var keys: [String] = []
  private var values: [String: Value] = [:]

  subscript(key: String) -> Value? {
    get { values[key] }
    set {
      if values[key] == nil, newValue != nil { keys.append(key) }
      values[key] = newValue
    }
  }

  var elements: [(key: String, value: Value)] {
    keys.compactMap { key in values[key].map { (key, $0) } }
  }
}

/// JSON の値の読み取り(Dart の json_serializable と同じく、型が違えば読めない扱い)。
enum JSONValue {
  /// 数値の整数。JSONSerialization は真偽値も NSNumber で返すので除く。
  /// 小数や Int に収まらない値は nil(`Int(_:)` で変換すると範囲外で落ちるため `exactly` で見る)。
  static func integer(_ value: Any?) -> Int? {
    guard let number = value as? NSNumber, !isBoolean(number) else { return nil }
    return Int(exactly: number.doubleValue)
  }

  static func number(_ value: Any?) -> Double? {
    guard let number = value as? NSNumber, !isBoolean(number) else { return nil }
    return number.doubleValue
  }

  static func boolean(_ value: Any?) -> Bool? {
    guard let number = value as? NSNumber, isBoolean(number) else { return nil }
    return number.boolValue
  }

  static func isBoolean(_ number: NSNumber) -> Bool {
    CFGetTypeID(number) == CFBooleanGetTypeID()
  }
}
