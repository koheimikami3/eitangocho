import EitangochoData
import Foundation

/// 書き出し・同期の JSON のトップレベル(Flutter 版の WordExportFile と同じ形)。
/// DB の行を直接書かない(スキーマの変更の影響を切り離すため)。
struct ExportFile: Encodable {
  var version: Int
  var exportedAt: Date
  var words: [Entry]
  var deletions: [Deletion]

  private enum CodingKeys: String, CodingKey {
    case version, exportedAt, words, deletions
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(version, forKey: .version)
    try container.encode(ExportDate.format(exportedAt), forKey: .exportedAt)
    try container.encode(words, forKey: .words)
    try container.encode(deletions, forKey: .deletions)
  }

  /// 削除された 1 単語(トゥームストーン)。version 2 で追加。
  struct Deletion: Encodable {
    var word: String
    var deletedAt: Date

    private enum CodingKeys: String, CodingKey { case word, deletedAt }

    func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(word, forKey: .word)
      try container.encode(ExportDate.format(deletedAt), forKey: .deletedAt)
    }
  }

  /// 1 単語。`id` は含めない(取り込む側で採番し、単語の文字列で突き合わせる)。
  ///
  /// JSON のキーは訳の言語によらず `japanese` / `exampleJa` のまま
  /// (古い版の端末と同期ファイルを読み書きし合うため。docs/design.md「多言語化」)。
  struct Entry: Encodable {
    var word: String
    var meaning: String
    var ipa = ""
    /// 品詞の名前。知らない値を捨てて復元できるよう、文字列のまま持つ。
    var partsOfSpeech: [String] = []
    var exampleEn = ""
    var exampleTranslation = ""
    /// 訳の言語。v2.5.0 より前の版が書いたファイルには無いので、無ければ日本語。
    /// 知らない値もそのまま持ち回す(新しい版が足した言語を古い版で消さないため)。
    var translationLanguage = "ja"
    var audioUrl = ""
    var isLearned = false
    var lastReviewedAt: Date?
    var correctCount = 0
    var createdAt: Date?
    var updatedAt: Date?

    private enum CodingKeys: String, CodingKey {
      case word
      case meaning = "japanese"
      case ipa, partsOfSpeech, exampleEn
      case exampleTranslation = "exampleJa"
      case translationLanguage, audioUrl, isLearned, lastReviewedAt, correctCount, createdAt, updatedAt
    }

    init(_ word: Word) {
      self.word = word.word
      meaning = word.meaning
      ipa = word.ipa
      partsOfSpeech = word.partsOfSpeech.map(\.rawValue)
      exampleEn = word.exampleEn
      exampleTranslation = word.exampleTranslation
      translationLanguage = word.translationLanguage
      audioUrl = word.audioUrl
      isLearned = word.isLearned
      lastReviewedAt = word.lastReviewedAt
      correctCount = word.correctCount
      createdAt = word.createdAt
      updatedAt = word.updatedAt
    }

    /// JSON の 1 行を読む。Flutter 版(json_serializable)が読めない行は読めない扱いにする:
    /// オブジェクトでない、word / japanese が無いか文字列でない、既定値のある項目の型が違う、
    /// 日時が読めない、のどれかなら nil。知らないキーは無視する。
    init?(json: Any) {
      guard let object = json as? [String: Any],
        let word = object["word"] as? String,
        let meaning = object[CodingKeys.meaning.rawValue] as? String
      else { return nil }
      self.word = word
      self.meaning = meaning

      // 型が違えば nil(行ごと読めない扱い)。欠落・null は既定値。
      func string(_ key: CodingKeys, default value: String) -> String? {
        switch object[key.rawValue] {
        case nil, is NSNull: return value
        case let string as String: return string
        default: return nil
        }
      }
      // 外側の nil は型が違うか読めない日時、内側の nil は欠落・null。
      func date(_ key: CodingKeys) -> Date?? {
        switch object[key.rawValue] {
        case nil, is NSNull: return .some(nil)
        case let string as String:
          guard let date = ExportDate.parse(string) else { return .none }
          return .some(date)
        default: return .none
        }
      }

      guard let ipa = string(.ipa, default: ""),
        let exampleEn = string(.exampleEn, default: ""),
        let exampleTranslation = string(.exampleTranslation, default: ""),
        let translationLanguage = string(.translationLanguage, default: "ja"),
        let audioUrl = string(.audioUrl, default: ""),
        let lastReviewedAt = date(.lastReviewedAt),
        let createdAt = date(.createdAt),
        let updatedAt = date(.updatedAt)
      else { return nil }
      self.ipa = ipa
      self.exampleEn = exampleEn
      self.exampleTranslation = exampleTranslation
      self.translationLanguage = translationLanguage
      self.audioUrl = audioUrl
      self.lastReviewedAt = lastReviewedAt
      self.createdAt = createdAt
      self.updatedAt = updatedAt

      switch object[CodingKeys.partsOfSpeech.rawValue] {
      case nil, is NSNull: partsOfSpeech = []
      case let list as [Any]:
        let names = list.compactMap { $0 as? String }
        guard names.count == list.count else { return nil }
        partsOfSpeech = names
      default: return nil
      }

      switch object[CodingKeys.isLearned.rawValue] {
      case nil, is NSNull: isLearned = false
      case let value:
        guard let bool = JSONValue.boolean(value) else { return nil }
        isLearned = bool
      }

      switch object[CodingKeys.correctCount.rawValue] {
      case nil, is NSNull: correctCount = 0
      case let value:
        // Dart は `(json['correctCount'] as num?)?.toInt()` で読む(小数は切り捨て)。
        guard let number = JSONValue.number(value) else { return nil }
        correctCount = Int(number.rounded(.towardZero))
      }
    }

    func encode(to encoder: any Encoder) throws {
      // Dart の書き出しと同じく、null の項目も省かずに書く。
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(word, forKey: .word)
      try container.encode(meaning, forKey: .meaning)
      try container.encode(ipa, forKey: .ipa)
      try container.encode(partsOfSpeech, forKey: .partsOfSpeech)
      try container.encode(exampleEn, forKey: .exampleEn)
      try container.encode(exampleTranslation, forKey: .exampleTranslation)
      try container.encode(translationLanguage, forKey: .translationLanguage)
      try container.encode(audioUrl, forKey: .audioUrl)
      try container.encode(isLearned, forKey: .isLearned)
      try container.encode(lastReviewedAt.map(ExportDate.format), forKey: .lastReviewedAt)
      try container.encode(correctCount, forKey: .correctCount)
      try container.encode(createdAt.map(ExportDate.format), forKey: .createdAt)
      try container.encode(updatedAt.map(ExportDate.format), forKey: .updatedAt)
    }
  }
}
