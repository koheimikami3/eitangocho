import EitangochoData

/// WordInfoProvider が返す単語情報。取得できなかった項目は空文字 / 空の配列。
public struct WordInfo: Equatable, Sendable {
  public var word: String
  public var ipa: String
  public var partsOfSpeech: [PartOfSpeech]
  public var meaning: String
  public var exampleEn: String
  public var exampleTranslation: String

  /// meaning / exampleTranslation を何語で取得したか(words に保存する)。
  public var translationLanguage: TranslationLanguage

  /// 発音 mp3 の URL。kaikki に切り替えてから取得しておらず常に空
  /// (docs/design.md)。words の同名の列を埋める経路だけ残している。
  public var audioUrl: String

  public init(
    word: String,
    ipa: String = "",
    partsOfSpeech: [PartOfSpeech] = [],
    meaning: String = "",
    exampleEn: String = "",
    exampleTranslation: String = "",
    translationLanguage: TranslationLanguage = .ja,
    audioUrl: String = ""
  ) {
    self.word = word
    self.ipa = ipa
    self.partsOfSpeech = partsOfSpeech
    self.meaning = meaning
    self.exampleEn = exampleEn
    self.exampleTranslation = exampleTranslation
    self.translationLanguage = translationLanguage
    self.audioUrl = audioUrl
  }
}

/// 英例文と、その対訳。対訳が取れないソースもあるため translation は空になりうる。
public struct ExampleSentence: Equatable, Sendable {
  public var en: String
  public var translation: String

  public init(en: String, translation: String = "") {
    self.en = en
    self.translation = translation
  }
}

/// WordInfoProvider の取得失敗(ネットワーク・API エラー等)。
/// 「辞書に未収録」はエラーではなく fetch の nil 返却で表す。
public struct WordInfoError: Error, Sendable, CustomStringConvertible {
  public var message: String
  public var cause: String?

  public init(_ message: String, cause: (any Error)? = nil) {
    self.message = message
    self.cause = cause.map { String(describing: $0) }
  }

  public var description: String { "WordInfoError: \(message)" }
}

/// 単語情報の自動取得を抽象化する(将来 LLM 実装への差し替えを可能にするため)。
/// 実装は DictionaryWordInfoProvider(kaikki + Tatoeba + EJDict)。
public protocol WordInfoProvider: Sendable {
  /// 辞書に未収録の場合は nil を返す。ネットワーク等の失敗は WordInfoError を投げる。
  func fetch(_ word: String) async throws -> WordInfo?
}
