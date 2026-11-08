import EitangochoData
import Foundation

/// WordInfoProvider の辞書ベース実装(事前生成辞書 + kaikki + Tatoeba + EJDict + DeepL)。
///
/// 訳は訳の言語(TranslationLanguage)で取得する。日本語・繁体字・韓国語では同梱の
/// 事前生成辞書を最優先し、載っている語は通信せずにその値だけを返す。
/// 載っていない語は、日本語なら同梱の EJDict、それ以外の言語は kaikki の訳語を使う。
/// 英語の語義は kaikki の語義の文から採る。
/// 依存はすべて init で受け取り、テストで差し替えられるようにする。
public struct DictionaryWordInfoProvider: WordInfoProvider {
  private let prebuiltDictionary: PrebuiltDictionary
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
    prebuiltDictionary: PrebuiltDictionary,
    kaikkiClient: KaikkiClient,
    tatoebaClient: TatoebaClient,
    deeplClient: DeeplClient,
    cacheDao: DictionaryCacheDao,
    ejdictDao: EjdictDao,
    ensureEjdictImported: @escaping @Sendable () async -> Void,
    getDeeplApiKey: @escaping @Sendable () async -> String,
    getTranslationLanguage: @escaping @Sendable () async -> TranslationLanguage
  ) {
    self.prebuiltDictionary = prebuiltDictionary
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
    let normalized = normalizeHeadword(word).lowercased()
    let language = await getTranslationLanguage()

    // 0. 事前生成辞書に載っていれば、その値だけで返す。訳・例文・例文の訳を検査済みの値で
    //    揃えて作ってあり、取得経路で引き直すと質が下がるうえ通信が要るため。
    //    載っていなければ、書き方の違い(lookupVariants)でも引く。
    //    見出しは入力のまま返す(書き方の違いで、原形への置き換えではないため)。
    for spelling in [normalized] + Self.lookupVariants(of: normalized) {
      if let entry = await prebuiltDictionary.lookup(spelling, language: language) {
        return Self.wordInfo(normalized, entry, language: language)
      }
    }

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

    // 1.5 活用形(ran・gave up)なら、その原形が事前生成辞書に載っていれば原形の値を返す。
    //     WordInfo.word を原形にするので、登録の見出しも原形に置き換わる。
    if let entries {
      for base in Self.baseForms(entries, of: normalized) {
        if let entry = await prebuiltDictionary.lookup(base, language: language) {
          return Self.wordInfo(base, entry, language: language)
        }
      }
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
    // 英単語として実在が確かめられる語(kaikki か EJDict に見出しがある)だけを、辞書に無かった語に数える。
    // Tatoeba だけで埋まった語は綴り間違いや入力の断片がありうるので数えない(計測で入力そのものを送るため)。
    // 辞書に語があって韓国語の訳だけが無い語も数える。次にどの語の韓国語を作るかを選ぶのに使うため。
    info.prebuiltDictionaryMiss =
      PrebuiltDictionary.covers(language) && (!(entries ?? []).isEmpty || meaning != nil)

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

  /// 綴りの候補の最大数。
  static let maxSpellingSuggestions = 3

  /// 綴りの候補の 2 段目(近い綴り)を探す最短の文字数。短い語は 1 文字違いの語が多すぎて当てにならない。
  static let minSuggestionLength = 4

  /// 綴りを誤ったとみられる語の候補。事前生成辞書に(書き方の違いでも)当たる語には出さない
  /// (`loose` は Wiktionary に `lose` の誤りの語義も持つが、それ自体が普通の語のため)。
  ///
  /// 1. kaikki の語義がすべて綴り違い(`alt-of`・`misspelling`)で、誤りの語義があれば、その行き先
  ///    (Wiktionary が記録した正しい綴り)。fetch の直後に呼ぶ前提で、キャッシュだけを見る(通信しない)
  /// 2. kaikki にも EJDict にも見出しが無い 1 語なら、事前生成辞書の綴りが近い見出し
  ///    (候補を押せば辞書の値がそろう語に限るため)
  public func spellingSuggestions(for word: String) async -> [String] {
    let normalized = normalizeHeadword(word).lowercased()
    guard !normalized.isEmpty else { return [] }
    for spelling in [normalized] + Self.lookupVariants(of: normalized)
    where await prebuiltDictionary.contains(spelling) {
      return []
    }

    let entriesJson = try? await cacheDao.find(normalized)
    let entries = (try? entriesJson.map(KaikkiClient.parseEntries)) ?? []
    let senses = entries.flatMap(\.senses)
    if !senses.isEmpty {
      guard senses.allSatisfy({ $0.tags.contains("alt-of") || $0.tags.contains("misspelling") }) else { return [] }
      var suggestions: [String] = []
      for sense in senses where sense.tags.contains("misspelling") {
        for altOf in sense.altOf {
          let target = normalizeHeadword(altOf.word ?? "").lowercased()
          guard !target.isEmpty, target != normalized, !suggestions.contains(target) else { continue }
          suggestions.append(target)
        }
      }
      return Array(suggestions.prefix(Self.maxSpellingSuggestions))
    }

    guard !normalized.contains(" "), normalized.count >= Self.minSuggestionLength else { return [] }
    await ensureEjdictImported()
    if (try? await ejdictDao.lookup(normalized)) != nil { return [] }
    return await prebuiltDictionary.nearestHeadwords(to: normalized, limit: Self.maxSpellingSuggestions)
  }

  /// 事前生成辞書に無かったときに試す、書き方の違い(試す順、入力そのものは含まない)。
  ///
  /// ハイフンと空白(hyphenVariants)、句の中の代名詞や記号(placeholderVariants)、
  /// 句の末尾の語の単数・複数(pluralVariants)の順。
  static func lookupVariants(of word: String) -> [String] {
    var variants: [String] = []
    for variant in hyphenVariants(of: word) + placeholderVariants(of: word) + pluralVariants(of: word)
    where variant != word && !variants.contains(variant) {
      variants.append(variant)
    }
    return variants
  }

  /// 空白をハイフンにする(ping pong → ping-pong)と、ハイフンを抜いてつなぐ(e-mail → email)の 2 つだけ。
  /// ハイフンを空白にする向きは試さない。`go-to`(定番の)が `go to`(…へ行く)に当たるように、
  /// 別の語の訳を返してしまうため。
  static func hyphenVariants(of word: String) -> [String] {
    var variants: [String] = []
    if word.contains(" ") { variants.append(word.replacingOccurrences(of: " ", with: "-")) }
    if word.contains("-") { variants.append(word.replacingOccurrences(of: "-", with: "")) }
    return variants
  }

  /// 句の中の語を、辞書の句の書き方に替える候補。辞書の句は目的語や所有格を
  /// `someone`・`something`・`one's`・`oneself` で書く(`keep one's word`)が、利用者は
  /// 例文のまま(`keep my word`)や記号(`put ~ in perspective`)で入力するため。
  static let placeholderReplacements: [String: [String]] = {
    var table: [String: [String]] = [
      "her": ["one's", "someone's", "someone"],
      "it": ["something"],
      "~": ["something", "someone"], "...": ["something", "someone"], "…": ["something", "someone"],
      "sth": ["something"], "sb": ["someone"], "sb's": ["one's", "someone's"], "somebody": ["someone"],
      "somebody's": ["someone's", "one's"], "one's": ["someone's"], "someone's": ["one's"],
    ]
    for word in ["my", "your", "his", "its", "our", "their"] { table[word] = ["one's", "someone's"] }
    for word in ["me", "him", "us", "them", "you"] { table[word] = ["someone"] }
    for word in ["myself", "yourself", "himself", "herself", "itself", "ourselves", "yourselves", "themselves"] {
      table[word] = ["oneself"]
    }
    return table
  }()

  /// 句の中の代名詞・記号を辞書の書き方に替えた候補。替える語が少ない順。
  /// 組み合わせが増えすぎないよう、替える候補にするのは先頭から 3 語まで。
  static func placeholderVariants(of word: String) -> [String] {
    let tokens = word.split(separator: " ").map(String.init)
    guard tokens.count > 1 else { return [] }
    var replaceable = 0
    // 語ごとの選択肢(先頭は元の語)と、替えた語の数
    var combos: [(tokens: [String], replaced: Int)] = [([], 0)]
    for token in tokens {
      var options = [token]
      if replaceable < 3, let replacements = placeholderReplacements[token] {
        options += replacements
        replaceable += 1
      }
      combos = combos.flatMap { combo in
        options.enumerated().map { index, option in (combo.tokens + [option], combo.replaced + (index == 0 ? 0 : 1)) }
      }
    }
    return combos.filter { $0.replaced > 0 }
      .sorted { $0.replaced < $1.replaced }
      .map { $0.tokens.joined(separator: " ") }
  }

  /// 句(空白を含む語)の末尾の語の単数・複数を入れ替えた候補(potato chip ↔ potato chips)。
  /// 1 語の複数形は kaikki の form_of で原形に寄せられるが、複合名詞は kaikki に項目が無いことが多いため。
  static func pluralVariants(of word: String) -> [String] {
    guard let space = word.lastIndex(of: " ") else { return [] }
    let head = String(word[...space])
    let last = String(word[word.index(after: space)...])
    var forms: [String] = []
    if last.hasSuffix("ies") {
      forms.append(String(last.dropLast(3)) + "y")
    } else if last.hasSuffix("es") {
      forms += [String(last.dropLast(2)), String(last.dropLast())]
    } else if last.hasSuffix("s") && !last.hasSuffix("ss") {
      forms.append(String(last.dropLast()))
    } else if ["s", "x", "z", "ch", "sh"].contains(where: last.hasSuffix) {
      forms.append(last + "es")
    } else if last.hasSuffix("y"), let before = last.dropLast().last, !"aeiou".contains(before) {
      forms += [String(last.dropLast()) + "ies", last + "s"]
    } else {
      forms.append(last + "s")
    }
    return forms.map { head + $0 }
  }

  /// 活用形の語義(`simple past of run`)が指す原形を、出てきた順に重複なく返す。
  ///
  /// `ran` は run と rin(古語)の両方を指すので、呼ぶ側が辞書に載る最初の語を採る。
  /// `found`・`left` のように自分の意味も持つ語は、それ自体が辞書に載っていれば
  /// ここまで来ない(辞書に無ければ、活用形として原形に寄せる)。
  static func baseForms(_ entries: [KaikkiEntry], of word: String) -> [String] {
    var bases: [String] = []
    for sense in entries.flatMap(\.senses) {
      for formOf in sense.formOf {
        let base = normalizeHeadword(formOf.word ?? "").lowercased()
        guard !base.isEmpty, base != word, !bases.contains(base) else { continue }
        bases.append(base)
      }
    }
    return bases
  }

  /// 事前生成辞書の値を WordInfo にする。
  static func wordInfo(_ word: String, _ entry: PrebuiltEntry, language: TranslationLanguage) -> WordInfo {
    WordInfo(
      word: word,
      ipa: entry.ipa,
      partsOfSpeech: entry.partsOfSpeech,
      meaning: entry.meaning,
      exampleEn: entry.exampleEn,
      exampleTranslation: entry.exampleTranslation,
      translationLanguage: language
    )
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
