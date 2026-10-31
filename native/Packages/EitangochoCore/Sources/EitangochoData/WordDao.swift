import Foundation
import GRDB

/// 登録時に渡す単語の内容。id・作成日時・更新日時は WordDao が付ける。
public struct NewWord: Sendable {
  public var word: String
  public var meaning: String
  public var ipa: String
  public var partsOfSpeech: [PartOfSpeech]
  public var exampleEn: String
  public var exampleTranslation: String
  public var translationLanguage: String
  public var audioUrl: String

  public init(
    word: String,
    meaning: String,
    ipa: String = "",
    partsOfSpeech: [PartOfSpeech] = [],
    exampleEn: String = "",
    exampleTranslation: String = "",
    translationLanguage: String = "ja",
    audioUrl: String = ""
  ) {
    self.word = word
    self.meaning = meaning
    self.ipa = ipa
    self.partsOfSpeech = partsOfSpeech
    self.exampleEn = exampleEn
    self.exampleTranslation = exampleTranslation
    self.translationLanguage = translationLanguage
    self.audioUrl = audioUrl
  }
}

/// 編集で書き換える単語の内容(編集画面に出している項目)。
public struct WordEdit: Sendable {
  public var word: String
  public var meaning: String
  public var ipa: String
  public var partsOfSpeech: [PartOfSpeech]
  public var exampleEn: String
  public var exampleTranslation: String

  public init(
    word: String,
    meaning: String,
    ipa: String,
    partsOfSpeech: [PartOfSpeech],
    exampleEn: String,
    exampleTranslation: String
  ) {
    self.word = word
    self.meaning = meaning
    self.ipa = ipa
    self.partsOfSpeech = partsOfSpeech
    self.exampleEn = exampleEn
    self.exampleTranslation = exampleTranslation
  }
}

/// 取り込み(同期・手動インポート)で書く単語の内容。
///
/// 登録・編集と違い、作成日時・更新日時は WordDao が付けず、ファイル側の値を
/// そのまま書く(他端末で付いた日時を保たないと、競合の判定が狂うため)。
public struct ImportedWord: Sendable {
  public var word: String
  public var meaning: String
  public var ipa: String
  public var partsOfSpeech: [PartOfSpeech]
  public var exampleEn: String
  public var exampleTranslation: String
  public var translationLanguage: String
  public var audioUrl: String
  public var isLearned: Bool
  public var lastReviewedAt: Date?
  public var correctCount: Int
  public var createdAt: Date
  public var updatedAt: Date

  public init(
    word: String,
    meaning: String,
    ipa: String = "",
    partsOfSpeech: [PartOfSpeech] = [],
    exampleEn: String = "",
    exampleTranslation: String = "",
    translationLanguage: String = "ja",
    audioUrl: String = "",
    isLearned: Bool = false,
    lastReviewedAt: Date? = nil,
    correctCount: Int = 0,
    createdAt: Date,
    updatedAt: Date
  ) {
    self.word = word
    self.meaning = meaning
    self.ipa = ipa
    self.partsOfSpeech = partsOfSpeech
    self.exampleEn = exampleEn
    self.exampleTranslation = exampleTranslation
    self.translationLanguage = translationLanguage
    self.audioUrl = audioUrl
    self.isLearned = isLearned
    self.lastReviewedAt = lastReviewedAt
    self.correctCount = correctCount
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

/// 取り込みで既存の単語に書く変更。
public enum WordImportUpdate: Sendable {
  /// 内容をファイル側で上書きする。word・createdAt は書かない
  /// (DB 側の表記・作成日時を維持するため)。
  case content(ImportedWord)

  /// クイズの回答の実績(最終出題日時・正解回数)だけを書く(内容はこちらが新しいとき)。
  /// 値は取り込み側で決めた最終の値で、updatedAt は変えない。
  case quizProgress(lastReviewedAt: Date?, correctCount: Int)
}

/// words / deleted_words へのクエリを集約する(画面から DB を直接触らない規約)。
/// 登録・編集での createdAt / updatedAt の付与は、呼び出し側でなくここが受け持つ。
public struct WordDao: Sendable {
  let writer: any DatabaseWriter

  /// 単語の同一判定キー(削除ログ・重複登録の検出・同期のマージに使う)。
  /// 大文字小文字・前後空白の違いで別の単語扱いにならないようにする。
  public static func matchKey(_ word: String) -> String {
    word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  }

  private static let allWordsSQL = "SELECT * FROM words ORDER BY created_at DESC, id DESC"

  /// 同じ単語が既に登録されていれば返す(重複登録の検出用)。
  /// `excludingId` を渡すとその 1 件を除いて探す(編集で自分自身に当たらないため)。
  ///
  /// DB に UNIQUE 制約は置いていない(既存端末に重複が残っている可能性があり、
  /// 制約を足すとマイグレーションと同期の取り込みが失敗しうる)。
  /// 重複の抑止はこのクエリを使うアプリ側の検証だけで行う。
  public func findByWord(_ word: String, excludingId: Int64? = nil) async throws -> Word? {
    let key = Self.matchKey(word)
    return try await writer.read { db in
      if let excludingId {
        return try Word.fetchOne(
          db, sql: "SELECT * FROM words WHERE lower(word) = ? AND id != ? LIMIT 1",
          arguments: [key, excludingId])
      }
      return try Word.fetchOne(
        db, sql: "SELECT * FROM words WHERE lower(word) = ? LIMIT 1", arguments: [key])
    }
  }

  /// 登録日時の新しい順(同時刻は id の新しい順)の全件を、変わるたびに流す。
  public func observeAll() -> AsyncValueObservation<[Word]> {
    ValueObservation
      .tracking { db in try Word.fetchAll(db, sql: Self.allWordsSQL) }
      .values(in: writer)
  }

  /// observeAll と同じ並びで全件を 1 回だけ読む(書き出し用)。
  public func getAll() async throws -> [Word] {
    try await writer.read { db in try Word.fetchAll(db, sql: Self.allWordsSQL) }
  }

  /// 登録されている単語の件数(一覧を読まずに件数だけ知りたいとき用)。
  public func countWords() async throws -> Int {
    try await writer.read { db in try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM words") ?? 0 }
  }

  /// 単語を追加する。同じ単語の削除ログが残っていれば取り消す
  /// (取り消さないと、削除 → 再登録した単語が次の同期でまた消えてしまう)。
  @discardableResult
  public func insertWord(_ new: NewWord, now: Date = .now) async throws -> Int64 {
    let timestamp = DatabaseTimestamp.seconds(now)
    return try await writer.write { db in
      try db.execute(
        sql: """
          INSERT INTO words (word, ipa, japanese, parts_of_speech, example_en, example_ja,
                             translation_language, audio_url, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          """,
        arguments: [
          new.word, new.ipa, new.meaning, PartOfSpeech.encodeList(new.partsOfSpeech),
          new.exampleEn, new.exampleTranslation, new.translationLanguage, new.audioUrl,
          timestamp, timestamp,
        ])
      let id = db.lastInsertedRowID
      try Self.clearDeletion(db, word: new.word)
      return id
    }
  }

  /// 編集した内容を書き、updatedAt を進める。
  ///
  /// 単語名を変えて同一判定キーが変わったら、元のキーを削除ログに残す(1 トランザクション)。
  /// 同期では単語の文字列で突き合わせるので、ログが無いとクラウドに残る元の名前が
  /// 「ローカルに無い単語」として次の同期で戻ってくる(綴りを直すと 2 件になる)。
  /// 元のキーの単語が他にも残っているとき(古い端末の重複)は、その単語を消さないようログを残さない。
  /// 新しいキーの削除ログは登録と同じく取り消す。
  public func updateWord(id: Int64, _ edit: WordEdit, now: Date = .now) async throws {
    let timestamp = DatabaseTimestamp.seconds(now)
    try await writer.write { db in
      let previous = try String.fetchOne(db, sql: "SELECT word FROM words WHERE id = ?", arguments: [id])
      try db.execute(
        sql: """
          UPDATE words SET word = ?, ipa = ?, japanese = ?, parts_of_speech = ?,
                           example_en = ?, example_ja = ?, updated_at = ?
          WHERE id = ?
          """,
        arguments: [
          edit.word, edit.ipa, edit.meaning, PartOfSpeech.encodeList(edit.partsOfSpeech),
          edit.exampleEn, edit.exampleTranslation, timestamp, id,
        ])
      guard let previous else { return }
      let oldKey = Self.matchKey(previous)
      if oldKey != Self.matchKey(edit.word) {
        // 同期と同じキー(matchKey)で探す。SQL の lower() は ASCII しか小文字にせず前後の空白も残すので、
        // それで探すと残っている単語を見落とし、同期でその単語まで消してしまう。
        let remains = try String.fetchAll(db, sql: "SELECT word FROM words").contains { Self.matchKey($0) == oldKey }
        if !remains {
          try db.execute(
            sql: "INSERT OR REPLACE INTO deleted_words (word, deleted_at) VALUES (?, ?)",
            arguments: [oldKey, timestamp])
        }
      }
      try Self.clearDeletion(db, word: edit.word)
    }
  }

  /// 単語を削除し、同時に削除ログへ記録する(1 トランザクション)。
  /// ログが無いと、同期で相手のスナップショットからこの単語が復活する。
  public func deleteWord(id: Int64, now: Date = .now) async throws {
    try await writer.write { db in
      guard let word = try String.fetchOne(db, sql: "SELECT word FROM words WHERE id = ?", arguments: [id])
      else { return }
      try db.execute(sql: "DELETE FROM words WHERE id = ?", arguments: [id])
      try db.execute(
        sql: "INSERT OR REPLACE INTO deleted_words (word, deleted_at) VALUES (?, ?)",
        arguments: [Self.matchKey(word), DatabaseTimestamp.seconds(now)])
    }
  }

  /// 削除ログの全件(同期でクラウドへ送る用)。
  public func getDeletions() async throws -> [DeletedWord] {
    try await writer.read { db in try DeletedWord.fetchAll(db, sql: "SELECT * FROM deleted_words") }
  }

  /// `before` より古い削除ログを掃除する。
  /// ログを無期限に持ち続けるとスナップショットが膨らみ続けるため、
  /// 全端末が確実に同期し終える程度の期間だけ残す。
  public func pruneDeletions(before: Date) async throws {
    try await writer.write { db in
      try db.execute(
        sql: "DELETE FROM deleted_words WHERE deleted_at < ?",
        arguments: [DatabaseTimestamp.seconds(before)])
    }
  }

  public func setLearned(id: Int64, _ isLearned: Bool, now: Date = .now) async throws {
    try await writer.write { db in
      try db.execute(
        sql: "UPDATE words SET is_learned = ?, updated_at = ? WHERE id = ?",
        arguments: [isLearned, DatabaseTimestamp.seconds(now), id])
    }
  }

  /// クイズの回答を記録する。lastReviewedAt = now、知っていたら correctCount を +1。
  ///
  /// updatedAt は「単語の内容の編集」を表すものとして取っておくため、ここでは
  /// 進めない(同期でクイズの回答だけの端末が内容を上書きしないようにするため)。
  /// 加算は式で行い、読み取り → 書き込みの競合を避ける。
  public func recordQuizResult(id: Int64, knew: Bool, now: Date = .now) async throws {
    let timestamp = DatabaseTimestamp.seconds(now)
    try await writer.write { db in
      if knew {
        try db.execute(
          sql: "UPDATE words SET last_reviewed_at = ?, correct_count = correct_count + 1 WHERE id = ?",
          arguments: [timestamp, id])
      } else {
        try db.execute(
          sql: "UPDATE words SET last_reviewed_at = ? WHERE id = ?", arguments: [timestamp, id])
      }
    }
  }

  /// 取り込みの適用。登録・編集と違い、日時はファイル側の値をそのまま書く。
  /// 全体を 1 トランザクションで行い、途中で失敗しても中途半端な状態を残さない。
  ///
  /// `deleteIds` はファイル側の削除ログにより消す単語、`deletions` は取り込む
  /// 削除ログ本体(ローカルに該当の単語が無くても、第 3 の端末へ伝えるため
  /// ログだけは残す)。`inserts` した単語の削除ログは取り消す。
  public func importWords(
    inserts: [ImportedWord],
    updates: [(id: Int64, update: WordImportUpdate)],
    deleteIds: [Int64] = [],
    deletions: [DeletedWord] = []
  ) async throws {
    try await writer.write { db in
      for word in inserts {
        try db.execute(
          sql: """
            INSERT INTO words (word, ipa, japanese, parts_of_speech, example_en, example_ja,
                               translation_language, audio_url, is_learned, last_reviewed_at,
                               correct_count, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
          arguments: [
            word.word, word.ipa, word.meaning, PartOfSpeech.encodeList(word.partsOfSpeech),
            word.exampleEn, word.exampleTranslation, word.translationLanguage, word.audioUrl,
            word.isLearned, word.lastReviewedAt.map(DatabaseTimestamp.seconds), word.correctCount,
            DatabaseTimestamp.seconds(word.createdAt), DatabaseTimestamp.seconds(word.updatedAt),
          ])
      }
      for (id, update) in updates {
        switch update {
        case .content(let word):
          try db.execute(
            sql: """
              UPDATE words SET japanese = ?, ipa = ?, parts_of_speech = ?, example_en = ?,
                               example_ja = ?, translation_language = ?, audio_url = ?,
                               is_learned = ?, last_reviewed_at = ?, correct_count = ?,
                               updated_at = ?
              WHERE id = ?
              """,
            arguments: [
              word.meaning, word.ipa, PartOfSpeech.encodeList(word.partsOfSpeech), word.exampleEn,
              word.exampleTranslation, word.translationLanguage, word.audioUrl, word.isLearned,
              word.lastReviewedAt.map(DatabaseTimestamp.seconds), word.correctCount,
              DatabaseTimestamp.seconds(word.updatedAt), id,
            ])
        case .quizProgress(let lastReviewedAt, let correctCount):
          try db.execute(
            sql: "UPDATE words SET last_reviewed_at = ?, correct_count = ? WHERE id = ?",
            arguments: [lastReviewedAt.map(DatabaseTimestamp.seconds), correctCount, id])
        }
      }
      for id in deleteIds {
        try db.execute(sql: "DELETE FROM words WHERE id = ?", arguments: [id])
      }
      for deletion in deletions {
        // 既にローカルにある削除ログの方が新しければ残す
        // (古いスナップショットを取り込んでも記録が巻き戻らないように)。
        let existing = try Int64.fetchOne(
          db, sql: "SELECT deleted_at FROM deleted_words WHERE word = ?", arguments: [deletion.word]
        ).map(DatabaseTimestamp.date)
        if let existing, deletion.deletedAt <= existing { continue }
        try db.execute(
          sql: "INSERT OR REPLACE INTO deleted_words (word, deleted_at) VALUES (?, ?)",
          arguments: [deletion.word, DatabaseTimestamp.seconds(deletion.deletedAt)])
      }
      // 復活した単語の削除ログは取り消す。deletions を書いたあとに行わないと、
      // 同じ単語が「追加」と「削除ログ」の両方に載っていた場合に消し漏れる。
      for word in inserts {
        try Self.clearDeletion(db, word: word.word)
      }
    }
  }

  /// 指定の単語の削除ログを取り消す(再登録・取り込みでの復活時)。
  private static func clearDeletion(_ db: Database, word: String) throws {
    try db.execute(sql: "DELETE FROM deleted_words WHERE word = ?", arguments: [matchKey(word)])
  }
}
