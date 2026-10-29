import Foundation
import GRDB

/// 登録単語(`words` テーブルの 1 行)。
///
/// 列の名前と型は Flutter 版(drift)の `Words` テーブルと同じ。同じ DB ファイルを
/// 両方の版が開けるよう、列を変えるときは追加だけにする(docs/design.md「データ・同期」)。
public struct Word: Identifiable, Hashable, Sendable {
  public var id: Int64
  public var word: String
  public var ipa: String

  /// 訳語(必須)。言語は利用者の訳の言語で、多くは日本語。
  ///
  /// **SQL の列名は `japanese` のまま**。iCloud 同期の JSON・既存端末の DB と
  /// 名前をそろえ続けるため、多言語化では列を言語ごとに増やさず使い回している
  /// (docs/design.md「多言語化」)。Swift 側の名前だけを中立にしている。
  public var meaning: String
  public var partsOfSpeech: [PartOfSpeech]
  public var exampleEn: String

  /// 英例文の訳。`meaning` と同じ理由で SQL の列名は `example_ja` のまま。
  public var exampleTranslation: String

  /// `meaning` / `exampleTranslation` の言語(TranslationLanguage の storageCode)。
  /// 知らない値も書き換えずに持つ(新しい版が足した言語を古い版で消さないため)。
  public var translationLanguage: String

  /// 辞書 API の発音 mp3 URL。取得をやめて常に空だが、既存データと
  /// iCloud 同期の JSON フォーマットを壊さないため残している。
  public var audioUrl: String
  public var isLearned: Bool

  /// クイズで最後に出題した日時。出題順(selectQuizQuestions)に使う。
  public var lastReviewedAt: Date?
  public var correctCount: Int
  public var createdAt: Date

  /// 内容を編集した日時。同期の競合解決に使うため、内容の変更では必ず更新する
  /// (クイズの回答では更新しない。WordDao.recordQuizResult)。
  public var updatedAt: Date

  public init(
    id: Int64,
    word: String,
    ipa: String = "",
    meaning: String,
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
    self.id = id
    self.word = word
    self.ipa = ipa
    self.meaning = meaning
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

extension Word: FetchableRecord {
  public init(row: Row) {
    let lastReviewedAt: Int64? = row["last_reviewed_at"]
    self.init(
      id: row["id"],
      word: row["word"],
      ipa: row["ipa"],
      meaning: row["japanese"],
      partsOfSpeech: PartOfSpeech.decodeList(row["parts_of_speech"]),
      exampleEn: row["example_en"],
      exampleTranslation: row["example_ja"],
      translationLanguage: row["translation_language"],
      audioUrl: row["audio_url"],
      isLearned: row["is_learned"],
      lastReviewedAt: lastReviewedAt.map(DatabaseTimestamp.date),
      correctCount: row["correct_count"],
      createdAt: DatabaseTimestamp.date(row["created_at"]),
      updatedAt: DatabaseTimestamp.date(row["updated_at"])
    )
  }
}

/// 削除済み単語のログ(トゥームストーン、`deleted_words` テーブルの 1 行)。
///
/// スナップショット同期は「相手にあって自分に無い単語は追加」でマージするため、
/// words から消しただけでは、次の同期で相手のスナップショットから復活する。
/// 削除した事実をここに残し、`deletedAt` と相手の updatedAt を比べて判断する。
public struct DeletedWord: Hashable, Sendable {
  /// 削除された単語。trim + 小文字化したキーで持つ(WordDao.matchKey)。
  public var word: String
  public var deletedAt: Date

  public init(word: String, deletedAt: Date) {
    self.word = word
    self.deletedAt = deletedAt
  }
}

extension DeletedWord: FetchableRecord {
  public init(row: Row) {
    self.init(word: row["word"], deletedAt: DatabaseTimestamp.date(row["deleted_at"]))
  }
}
