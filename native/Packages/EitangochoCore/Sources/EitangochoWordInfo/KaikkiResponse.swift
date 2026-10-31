import Foundation

// kaikki.org(wiktextract)のレスポンスのうち、使う項目だけのモデル。
//
// 実レスポンスでは sounds / senses / examples が丸ごと欠落する語があり、
// sounds の要素も ipa を持つもの・audio だけのもの・rhymes だけのものが
// 混在する。どの項目も必須にせず、欠落・null・型の違いは空として読む
// (CLAUDE.md 規約)。キャッシュには同じ形で書き戻す(Flutter 版の toJson と同じキー)。

/// 1 エントリ = 1 品詞。使うのは word / pos / sounds / senses / translations だけ。
public struct KaikkiEntry: Codable, Equatable, Sendable {
  public var word: String?
  public var pos: String?
  public var sounds: [KaikkiSound]
  public var senses: [KaikkiSense]
  public var translations: [KaikkiTranslation]

  public init(
    word: String? = nil, pos: String? = nil, sounds: [KaikkiSound] = [], senses: [KaikkiSense] = [],
    translations: [KaikkiTranslation] = []
  ) {
    self.word = word
    self.pos = pos
    self.sounds = sounds
    self.senses = senses
    self.translations = translations
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    word = container.lenient(String.self, .word)
    pos = container.lenient(String.self, .pos)
    sounds = container.lenientList(KaikkiSound.self, .sounds)
    senses = container.lenientList(KaikkiSense.self, .senses)
    translations = container.lenientList(KaikkiTranslation.self, .translations)
  }
}

/// 発音。ipa は `/əbˈteɪn/`(音素表記)と `[ˈlɪɾ.ɚ.ə.t͡ʃɚ]`(異音表記)の
/// 両方が来る。tags は `US` / `General-American` / `Received-Pronunciation`
/// などの方言ラベル。
public struct KaikkiSound: Codable, Equatable, Sendable {
  public var ipa: String?
  public var tags: [String]

  public init(ipa: String? = nil, tags: [String] = []) {
    self.ipa = ipa
    self.tags = tags
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    ipa = container.lenient(String.self, .ipa)
    tags = container.lenientList(String.self, .tags)
  }
}

/// 訳語(Wiktionary の translations 節)。
///
/// 生のレスポンスは全言語ぶんを持ち、`give up` では 1 品詞に 243 件来る。
/// キャッシュへ詰め直す時点で訳の言語の分だけに絞る。
///
/// word は日本語なら漢字表記(`諦める`)で、中国語は `實現 /实现` のように
/// 繁体字と簡体字が並んで来る。同じ訳語が語義ごとに重複して来るため、使う側で畳む。
///
/// lang は言語名(`Chinese Mandarin` など)。北京語の訳語には `lang_code` が
/// `zh` で来るものがあり、それを見分けるためだけに読む。詰め直す時点で
/// `cmn` に揃えるので、キャッシュには書き出さない。
public struct KaikkiTranslation: Codable, Equatable, Sendable {
  public var word: String?
  public var langCode: String?
  public var lang: String?

  enum CodingKeys: String, CodingKey {
    case word
    case langCode = "lang_code"
    case lang
  }

  public init(word: String? = nil, langCode: String? = nil, lang: String? = nil) {
    self.word = word
    self.langCode = langCode
    self.lang = lang
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    word = container.lenient(String.self, .word)
    langCode = container.lenient(String.self, .langCode)
    lang = container.lenient(String.self, .lang)
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(word, forKey: .word)
    try container.encodeIfPresent(langCode, forKey: .langCode)
  }
}

/// 語義。glosses は語義の文で、下位の語義では `[上位の語義, この語義]` の
/// ように上位から並ぶ(最後がこの語義そのもの)。tags は `obsolete` /
/// `archaic` / `form-of` などの注記で、英語の語義を選ぶときの除外に使う。
public struct KaikkiSense: Codable, Equatable, Sendable {
  public var glosses: [String]
  public var tags: [String]
  public var examples: [KaikkiExample]

  public init(glosses: [String] = [], tags: [String] = [], examples: [KaikkiExample] = []) {
    self.glosses = glosses
    self.tags = tags
    self.examples = examples
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    glosses = container.lenientList(String.self, .glosses)
    tags = container.lenientList(String.self, .tags)
    examples = container.lenientList(KaikkiExample.self, .examples)
  }
}

/// 例文。type は `example`(用例)と `quotation`(出典付きの文献引用)があり、
/// 後者は長い引用なので単語帳には使わない。tags に `collocation` が付くものは
/// `obtain permission` のような句の断片。
public struct KaikkiExample: Codable, Equatable, Sendable {
  public var text: String?
  public var type: String?
  public var tags: [String]

  public init(text: String? = nil, type: String? = nil, tags: [String] = []) {
    self.text = text
    self.type = type
    self.tags = tags
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    text = container.lenient(String.self, .text)
    type = container.lenient(String.self, .type)
    tags = container.lenientList(String.self, .tags)
  }
}

extension KeyedDecodingContainer {
  /// 欠落・null・型の違いを nil として読む。
  func lenient<T: Decodable>(_ type: T.Type, _ key: Key) -> T? {
    try? decodeIfPresent(T.self, forKey: key)
  }

  /// 欠落・null・型の違いを空の配列として読む。要素が 1 つ壊れていても他は残す。
  func lenientList<T: Decodable>(_ type: T.Type, _ key: Key) -> [T] {
    guard var items = try? nestedUnkeyedContainer(forKey: key) else { return [] }
    var result: [T] = []
    while !items.isAtEnd {
      if let item = try? items.decode(T.self) {
        result.append(item)
      } else {
        // 読めない要素を読み飛ばして先へ進める。
        _ = try? items.decode(Skip.self)
      }
    }
    return result
  }
}

/// 読み飛ばし用。どんな JSON の値でも成功する。
private struct Skip: Decodable {
  init(from decoder: any Decoder) throws {}
}
