import EitangochoData
import Foundation

/// WordInfoProvider の辞書ベース実装(kaikki + Tatoeba + EJDict + DeepL)。
///
/// 訳は訳の言語(TranslationLanguage)で取得する。日本語は同梱の EJDict を
/// 優先し、それ以外の言語は kaikki の訳語だけを使う(同梱できる辞書が無い)。
/// 英語の語義は kaikki の語義の文から採る。
/// 依存はすべて init で受け取り、テストで差し替えられるようにする。
public struct DictionaryWordInfoProvider: WordInfoProvider {
  private let kaikkiClient: KaikkiClient
  private let tatoebaClient: TatoebaClient
  private let deeplClient: DeeplClient
  private let cacheDao: DictionaryCacheDao
  private let ejdictDao: EjdictDao

  /// EJDict の初回取込完了を待つ(バックグラウンド取込中に自動入力された場合に備える)
  private let ensureEjdictImported: @Sendable () async -> Void
  private let getDeeplApiKey: @Sendable () async -> String

  /// 訳の言語(設定)。fetch のたびに引き、設定の変更をすぐ反映する。
  private let getTranslationLanguage: @Sendable () async -> TranslationLanguage

  public init(
    kaikkiClient: KaikkiClient,
    tatoebaClient: TatoebaClient,
    deeplClient: DeeplClient,
    cacheDao: DictionaryCacheDao,
    ejdictDao: EjdictDao,
    ensureEjdictImported: @escaping @Sendable () async -> Void,
    getDeeplApiKey: @escaping @Sendable () async -> String,
    getTranslationLanguage: @escaping @Sendable () async -> TranslationLanguage
  ) {
    self.kaikkiClient = kaikkiClient
    self.tatoebaClient = tatoebaClient
    self.deeplClient = deeplClient
    self.cacheDao = cacheDao
    self.ejdictDao = ejdictDao
    self.ensureEjdictImported = ensureEjdictImported
    self.getDeeplApiKey = getDeeplApiKey
    self.getTranslationLanguage = getTranslationLanguage
  }

  /// 例文として短すぎるものを弾く語数。`obtain permission` のような
  /// コロケーションの断片は単語帳の例文にならない。
  static let minExampleWords = 4

  /// kaikki の訳語から訳に採る最大件数。
  static let maxMeaningWords = 5

  /// 英語の語義から外すタグ。廃用・古風・方言・活用形の参照(`past participle
  /// of ...`)は、学習者が覚える意味にならない。
  static let excludedDefinitionTags: Set<String> = [
    "obsolete", "archaic", "rare", "dated", "dialectal", "historical", "nonstandard",
    "misspelling", "form-of", "alt-of",
  ]

  public func fetch(_ word: String) async throws -> WordInfo? {
    let normalized = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    let language = await getTranslationLanguage()

    // 1. kaikki: キャッシュ優先、miss なら取得し成功時のみ保存。
    //    取得に失敗しても例外にせず、EJDict の訳だけで登録を続けられるようにする
    //    (辞書ソースが落ちている間に登録フロー全体が死ぬのを防ぐ。
    //     Free Dictionary 時代は 502 のたびに登録できなくなっていた)。
    var entries: [KaikkiEntry]?
    var kaikkiFailure: (any Error)?
    do {
      var entriesJson = try await cacheDao.find(normalized)
      if entriesJson == nil {
        entriesJson = try await kaikkiClient.fetchEntriesJson(normalized)
        if let entriesJson { try await cacheDao.save(normalized, responseJson: entriesJson) }
      }
      entries = try entriesJson.map(KaikkiClient.parseEntries)
    } catch let error as WordInfoError {
      kaikkiFailure = error
    }

    // 2. EJDict の訳(取込完了を待ってから引く)。英和辞書なので日本語のときだけ。
    var meaning: String?
    if language == .ja {
      await ensureEjdictImported()
      meaning = try await ejdictDao.lookup(normalized)
    }

    // 3. 辞書が両方空振りで、しかも通信に失敗していたならエラーにする。
    //    「取得できない」を「辞書に未収録」と誤解させないため。オフラインなら
    //    続く Tatoeba も失敗するので、ここで打ち切ってよい。
    if entries == nil, meaning == nil, let kaikkiFailure { throw kaikkiFailure }

    // EJDict の語義を優先し、未収録のときだけ kaikki の訳語に落とす。
    // EJDict は英和辞典の語義で情報量が多く、kaikki 側は訳語の列挙なので
    // 出番は EJDict が持たない見出し(句動詞がほぼこれに当たる)だけになる。
    var info = mapEntries(normalized, entries ?? [], language: language)
    if let meaning { info.meaning = meaning }

    // 4. Tatoeba の例文を優先する。訳が対で付いてくるうえ、kaikki の例文より
    //    単語帳向き(kaikki 側は語義の説明が目的で、断片や文献引用が混ざる)。
    //    空振りしたときだけ kaikki の例文(訳なし)を使う。
    //
    //    **辞書が両方空振りでも引く**。kaikki の見出しがユーザーの入力とずれる句
    //    (`run out of` は Wiktionary の見出しが `run out` なので 404)では、
    //    ここが唯一の自動入力になる。単語 1 語では kaikki がほぼ埋めるため、
    //    この経路に来るのは実質そういう句と綴り間違いだけ。
    let example = await tatoebaClient.findExample(normalized, language: language)
    if let example {
      info.exampleEn = example.en
      info.exampleTranslation = example.translation
    }

    // 5. 辞書にも例文にも何も無ければ未収録として扱う(手動入力へ倒す)。
    if entries == nil, meaning == nil, example == nil { return nil }

    // 6. 訳がまだ無くキー設定済みなら DeepL で訳す(失敗は空のまま続行)。
    //    例文の訳を持たない言語(英語の語義)では訳さない。
    if language.translatesExamples, !info.exampleEn.isEmpty, info.exampleTranslation.isEmpty {
      let apiKey = await getDeeplApiKey()
      if !apiKey.isEmpty {
        info.exampleTranslation = await deeplClient.translate(info.exampleEn, apiKey: apiKey, to: language) ?? ""
      }
    }
    return info
  }

  /// kaikki のエントリ(1 件 = 1 品詞)を WordInfo に畳み込む。
  private func mapEntries(_ word: String, _ entries: [KaikkiEntry], language: TranslationLanguage) -> WordInfo {
    var partsOfSpeech: [PartOfSpeech] = []
    for entry in entries {
      let pos = Self.partOfSpeech(entry.pos)
      if !partsOfSpeech.contains(pos) { partsOfSpeech.append(pos) }
    }
    return WordInfo(
      word: word,
      ipa: Self.selectIpa(entries),
      partsOfSpeech: partsOfSpeech,
      meaning: language.usesDefinition
        ? Self.selectDefinition(entries) : Self.selectMeaning(entries, language: language),
      exampleEn: Self.selectExample(entries, word: word),
      translationLanguage: language
    )
  }

  /// kaikki の訳語のうち `language` のものを訳の文字列にまとめる。
  ///
  /// 同じ訳語が語義ごとに重複して来る(`give up` の「諦める」は 2 件)ので
  /// 畳み、EJDict の語義と同じ ` / ` 区切りで連結する。並びは kaikki が
  /// 返した順のままで、語義の主従は反映されない(`give up` は「降服する」が
  /// 先頭に来る)。**必須項目の欄が長大にならないよう maxMeaningWords で
  /// 打ち切る**。多義語では 10 件以上返ることがあるため。
  static func selectMeaning(_ entries: [KaikkiEntry], language: TranslationLanguage) -> String {
    var words: [String] = []
    for entry in entries {
      for translation in entry.translations where translation.langCode == language.kaikkiLangCode {
        let word = traditionalForm(
          (translation.word ?? "").trimmingCharacters(in: .whitespacesAndNewlines), language: language)
        guard !word.isEmpty, !words.contains(word) else { continue }
        words.append(word)
        if words.count == maxMeaningWords { return words.joined(separator: " / ") }
      }
    }
    return words.joined(separator: " / ")
  }

  /// kaikki の語義の文から英語の語義を 1 つ選ぶ(TranslationLanguage.enDefinition)。
  ///
  /// 先頭の品詞から順に見て、excludedDefinitionTags の付かない最初の語義を
  /// 採る。**1 文だけにする**。2 品詞目の語義を足しても名詞形の言い換えか、
  /// `vague` の「An indefinite expanse.」のような外れた意味がほとんどで、
  /// 欄が長くなるだけだったため。
  ///
  /// Wiktionary の語義の並びは使用頻度順とは限らない(語源ごとにエントリが
  /// 分かれ、古い語源が先に来る)。自動入力は下書きで、利用者が直せる前提。
  static func selectDefinition(_ entries: [KaikkiEntry]) -> String {
    for entry in entries {
      for sense in entry.senses {
        guard let last = sense.glosses.last,
          !sense.tags.contains(where: excludedDefinitionTags.contains)
        else { continue }
        // 下位の語義は [上位, この語義] の順で来るので、最後がこの語義
        let gloss = last.trimmingCharacters(in: .whitespacesAndNewlines)
        if !gloss.isEmpty { return gloss }
      }
    }
    return ""
  }

  /// 中国語の訳語から繁体字の表記だけを取り出す。
  ///
  /// kaikki の北京語の訳語は `實現 /实现`(繁体字 + ` /` + 簡体字)の形で来る。
  /// 両者が同じ字のとき(`完成`)は 1 つだけ。区切りを残すと訳の連結に使う
  /// ` / ` と紛れるため、先頭(繁体字)だけを採る。
  static func traditionalForm(_ word: String, language: TranslationLanguage) -> String {
    guard language == .zhHant, let separator = word.range(of: " /") else { return word }
    return word[..<separator.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /// 米音を優先して IPA を 1 つ選ぶ。
  ///
  /// kaikki は方言ごとに複数の発音を持ち、`tags` に `US` /
  /// `General-American` / `Received-Pronunciation` などが付く。
  /// `[ˈlɪɾ.ɚ.ə.t͡ʃɚ]` のような異音表記も混ざるので、`/` で囲まれた
  /// 音素表記だけを候補にする。方言タグが無い語(`obtain` など)は
  /// 最初の候補をそのまま使う。
  static func selectIpa(_ entries: [KaikkiEntry]) -> String {
    let candidates = entries.flatMap(\.sounds).filter { ($0.ipa ?? "").hasPrefix("/") }
    let usTags: Set<String> = ["US", "General-American"]
    let us = candidates.first { $0.tags.contains(where: usTags.contains) }
    return (us ?? candidates.first)?.ipa ?? ""
  }

  /// 例文を 1 つ選ぶ。見出し語を実際に含み、短すぎないものの中から最短を採る。
  ///
  /// kaikki の例文は語義ごとに付くため派生語の文が混ざり、`collocation`
  /// タグの断片(`obtain permission`)も含まれる。単語帳の例文は短いほど
  /// 覚えやすいので、条件を満たす中では最短を選ぶ。
  static func selectExample(_ entries: [KaikkiEntry], word: String) -> String {
    var candidates: [String] = []
    for entry in entries {
      for sense in entry.senses {
        for example in sense.examples {
          let text = (example.text ?? "").split(whereSeparator: \.isWhitespace).joined(separator: " ")
          guard !text.isEmpty, !example.tags.contains("collocation"),
            text.split(separator: " ").count >= minExampleWords,
            WordFormMatcher.containsWordForm(text, word)
          else { continue }
          candidates.append(text)
        }
      }
    }
    // 同じ長さなら先に出た方(Dart の安定な並べ替えと同じ結果)。
    return candidates.enumerated().min { ($0.element.count, $0.offset) < ($1.element.count, $1.offset) }?
      .element ?? ""
  }

  /// kaikki の pos は `adj` / `adv` と略される。それ以外(pron, prep, name 等)は other に落とす。
  static func partOfSpeech(_ raw: String?) -> PartOfSpeech {
    switch raw {
    case "verb": .verb
    case "noun": .noun
    case "adj": .adjective
    case "adv": .adverb
    default: .other
    }
  }
}
