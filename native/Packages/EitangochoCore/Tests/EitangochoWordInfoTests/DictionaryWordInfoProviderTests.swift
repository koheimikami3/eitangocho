import EitangochoData
import Foundation
import Testing

@testable import EitangochoWordInfo

/// kaikki の JSONL(1 行 1 品詞)。実レスポンスから必要な形だけ抜き出したもの。
/// - sounds は方言タグ付きが複数、異音表記 `[...]` も混ざる
/// - examples には collocation の断片と、派生語しか含まない文が混ざる
private let kaikkiFixture = """
  {"word":"serendipity","pos":"noun","sounds":[{"tags":["Received-Pronunciation"],"ipa":"/ˌsɛɹənˈdɪpɪti/"},{"tags":["US"],"ipa":"/ˌsɛɹənˈdɪpɪɾi/"},{"tags":["US"],"ipa":"[ˌsɛɹənˈdɪpɪɾi]"}],"senses":[{"examples":[{"text":"serendipity value","type":"example","tags":["collocation"]},{"text":"It was serendipity that brought them together.","type":"example"},{"text":"Their meeting was pure serendipity, unplanned and unexpected.","type":"example"}]}]}
  {"word":"serendipity","pos":"name","sounds":[],"senses":[]}

  """

/// 句動詞の実レスポンス(`give up`)から translations だけ抜き出したもの。
/// 「諦める」は語義違いで 2 件来る(畳んで 1 つにする)。
private let giveUpJsonl = """
  {"word":"give up","pos":"verb","senses":[],"translations":[{"lang":"Japanese","code":"ja","lang_code":"ja","sense":"surrender","alt":"こうふくする","roman":"kōfuku suru","word":"降服する"},{"lang":"Japanese","code":"ja","lang_code":"ja","sense":"stop, quit, desist","roman":"akirameru","word":"諦める"},{"lang":"Japanese","code":"ja","lang_code":"ja","sense":"abandon","alt":"あきらめる","roman":"akirameru","word":"諦める"},{"lang":"Japanese","code":"ja","lang_code":"ja","sense":"abandon","roman":"yameru","word":"やめる"}]}

  """

/// `achieve` の訳語(日本語と北京語)。北京語は「繁体字 /簡体字」の形で、
/// 両者が同じ字なら 1 つだけ来る。閩南語(nan-hbl)など他の中国語は使わない。
private let achieveJsonl = """
  {"word":"achieve","pos":"verb","senses":[],"translations":[{"lang":"Japanese","code":"ja","lang_code":"ja","word":"達成する"},{"lang":"Chinese Mandarin","code":"cmn","lang_code":"cmn","word":"實現 /实现"},{"lang":"Chinese","code":"nan-hbl","lang_code":"nan-hbl","word":"達成"},{"lang":"Chinese Mandarin","code":"cmn","lang_code":"cmn","word":"達到 /达到"},{"lang":"Chinese Mandarin","code":"cmn","lang_code":"cmn","word":"完成"}]}

  """

/// `achieve` の訳語(スペイン語とフランス語)。スペイン語の同じ訳語が語義ごとに重複して来る。
private let achieveEsFrJsonl = """
  {"word":"achieve","pos":"verb","senses":[],"translations":[{"lang":"French","code":"fr","lang_code":"fr","word":"accomplir"},{"lang":"French","code":"fr","lang_code":"fr","word":"réaliser"},{"lang":"Spanish","code":"es","lang_code":"es","word":"conseguir"},{"lang":"Spanish","code":"es","lang_code":"es","word":"lograr"},{"lang":"Spanish","code":"es","lang_code":"es","word":"conseguir"},{"lang":"Spanish","code":"es","lang_code":"es","word":"lograr"}]}

  """

/// `commute` の実レスポンスから語義の形だけ抜き出したもの。品詞ごとに語義が
/// 並び、廃用(obsolete)や活用形の参照(form-of)のタグが付く語義が混ざる。
/// 下位の語義は glosses が [上位, この語義] の順で来る。
private let commuteDefinitionJsonl = """
  {"word":"commute","pos":"verb","senses":[{"glosses":["To exchange."],"tags":["obsolete"]},{"glosses":["To reduce a sentence.","To reduce the sentence previously given."],"tags":["transitive"]}],"translations":[{"lang":"Japanese","code":"ja","lang_code":"ja","word":"減刑する"}]}
  {"word":"commute","pos":"noun","senses":[{"glosses":["A regular journey between two places, typically home and work."]}]}
  {"word":"commute","pos":"verb","senses":[{"glosses":["To regularly travel from one's home to one's workplace."]}]}
  {"word":"commuted","pos":"verb","senses":[{"glosses":["simple past of commute"],"tags":["form-of"]}]}

  """

/// Tatoeba のヒット 1 件分のレスポンス。
private func tatoebaHit(_ en: String, _ ja: String) -> String {
  json(["data": [["text": en, "translations": [["lang": "jpn", "text": ja]]]]])
}

/// Flutter 版の test/features/word_registration/data/dictionary_word_info_provider_test.dart の移植。
struct DictionaryWordInfoProviderTests {
  typealias Respond = @Sendable () -> StubURLProtocol.Response

  let database: AppDatabase
  let kaikkiCalls = Recorder()
  let tatoebaCalls = Recorder()
  let deeplCalls = Recorder()

  init() throws {
    database = try AppDatabase.inMemory()
  }

  /// kaikki / Tatoeba / DeepL のレスポンスを差し替えて組み立てる。
  private func makeProvider(
    kaikki: Respond? = nil,
    tatoeba: Respond? = nil,
    deepl: Respond? = nil,
    deeplApiKey: String = "",
    language: TranslationLanguage = .ja
  ) -> DictionaryWordInfoProvider {
    let (kaikkiCalls, tatoebaCalls, deeplCalls) = (kaikkiCalls, tatoebaCalls, deeplCalls)
    return DictionaryWordInfoProvider(
      kaikkiClient: KaikkiClient(
        session: StubURLProtocol.session { request, _ in
          kaikkiCalls.append(request)
          return kaikki?() ?? .init(status: 404, body: "not found")
        }),
      tatoebaClient: TatoebaClient(
        session: StubURLProtocol.session { request, _ in
          tatoebaCalls.append(request)
          return tatoeba?() ?? .init(status: 200, body: #"{"data":[]}"#)
        }),
      deeplClient: DeeplClient(
        session: StubURLProtocol.session { request, _ in
          deeplCalls.append(request)
          return deepl?() ?? .init(status: 403, body: "forbidden")
        }),
      cacheDao: database.dictionaryCacheDao,
      ejdictDao: database.ejdictDao,
      ensureEjdictImported: {},
      getDeeplApiKey: { deeplApiKey },
      getTranslationLanguage: { language }
    )
  }

  private func seedEjdict(_ entries: [String: String]) async throws {
    try await database.ejdictDao.bulkInsert(entries.map { ($0.key, $0.value) })
  }

  private func ok(_ body: String) -> Respond { { .init(status: 200, body: body) } }

  @Test("kaikki・EJDict 両ヒット: 全項目をマッピングし DeepL で例文を訳す")
  func mapsAllFields() async throws {
    try await seedEjdict(["serendipity": "思わぬ発見"])
    let provider = makeProvider(
      kaikki: ok(kaikkiFixture),
      deepl: ok(#"{"translations":[{"text":"二人を巡り合わせたのは偶然だった。"}]}"#),
      deeplApiKey: "key")

    let info = try #require(try await provider.fetch("serendipity"))

    #expect(info.word == "serendipity")
    #expect(info.meaning == "思わぬ発見")
    // name は other に落ちる
    #expect(info.partsOfSpeech == [.noun, .other])
    #expect(info.exampleTranslation == "二人を巡り合わせたのは偶然だった。")
  }

  @Test("IPA は米音(US / General-American)を優先し、音素表記だけを使う")
  func prefersUsIpa() async throws {
    let info = try await makeProvider(kaikki: ok(kaikkiFixture)).fetch("serendipity")
    #expect(info?.ipa == "/ˌsɛɹənˈdɪpɪɾi/")
  }

  @Test("方言タグが無い語は最初の IPA を使う")
  func firstIpaWithoutDialect() async throws {
    let provider = makeProvider(kaikki: ok(#"{"word":"obtain","pos":"verb","sounds":[{"ipa":"/əbˈteɪn/"}],"senses":[]}"#))
    #expect(try await provider.fetch("obtain")?.ipa == "/əbˈteɪn/")
  }

  @Test("例文は断片を避け、見出し語を含む中から最短を選ぶ")
  func picksShortestExample() async throws {
    let info = try await makeProvider(kaikki: ok(kaikkiFixture)).fetch("serendipity")
    // collocation の "serendipity value" と、より長い 2 件目は選ばれない
    #expect(info?.exampleEn == "It was serendipity that brought them together.")
  }

  @Test("見出し語を含まない例文しか無ければ例文は空")
  func emptyExampleWithoutHeadword() async throws {
    let provider = makeProvider(
      kaikki: ok(
        #"{"word":"negligible","pos":"adj","senses":[{"examples":[{"text":"He was negligent of his duties.","type":"example"}]}]}"#
      ))
    #expect(try await provider.fetch("negligible")?.exampleEn == "")
  }

  // 訳が対で付いてくるうえ、kaikki の例文より単語帳向きなため。
  @Test("Tatoeba の例文は kaikki の例文より優先される")
  func prefersTatoeba() async throws {
    let provider = makeProvider(kaikki: ok(kaikkiFixture), tatoeba: ok(tatoebaHit("What a serendipity!", "なんという偶然！")))

    let info = try #require(try await provider.fetch("serendipity"))

    #expect(info.exampleEn == "What a serendipity!")
    #expect(info.exampleTranslation == "なんという偶然！")
  }

  @Test("Tatoeba が空振りなら kaikki の例文を使い、訳は空のまま")
  func fallsBackToKaikkiExample() async throws {
    let info = try #require(try await makeProvider(kaikki: ok(kaikkiFixture)).fetch("serendipity"))

    #expect(tatoebaCalls.count == 1)
    #expect(info.exampleEn == "It was serendipity that brought them together.")
    #expect(info.exampleTranslation == "")
  }

  @Test("Tatoeba で訳が取れたら DeepL は呼ばない")
  func skipsDeeplWithTatoebaTranslation() async throws {
    let provider = makeProvider(
      kaikki: ok(kaikkiFixture), tatoeba: ok(tatoebaHit("What a serendipity!", "なんという偶然！")), deeplApiKey: "key")

    _ = try await provider.fetch("serendipity")

    #expect(deeplCalls.count == 0)
  }

  @Test("kaikki が未収録でも Tatoeba に例文があれば拾う")
  func tatoebaWithoutKaikki() async throws {
    try await seedEjdict(["serendipity": "思わぬ発見"])
    let provider = makeProvider(tatoeba: ok(tatoebaHit("What a serendipity!", "なんという偶然！")))

    let info = try #require(try await provider.fetch("serendipity"))

    #expect(info.exampleEn == "What a serendipity!")
    #expect(info.ipa == "")
  }

  @Test("kaikki 未収録・EJDict のみヒット: meaning のみの WordInfo を返す")
  func ejdictOnly() async throws {
    try await seedEjdict(["milksop": "意気地なし"])

    let info = try #require(try await makeProvider().fetch("milksop"))

    #expect(info.meaning == "意気地なし")
    #expect(info.ipa == "")
    #expect(info.exampleEn == "")
    #expect(info.partsOfSpeech.isEmpty)
  }

  // 句動詞は EJDict に無いので、ここが唯一の日本語訳の出所になる。
  @Test("EJDict が未収録なら kaikki の訳語を日本語訳に使う")
  func kaikkiTranslationsWithoutEjdict() async throws {
    let info = try await makeProvider(kaikki: ok(giveUpJsonl)).fetch("give up")
    // 語義ごとに重複する「諦める」は 1 つに畳み、EJDict と同じ区切りで繋ぐ。
    #expect(info?.meaning == "降服する / 諦める / やめる")
  }

  @Test("EJDict がヒットすれば kaikki の訳語は使わない")
  func ejdictWinsOverKaikki() async throws {
    try await seedEjdict(["give up": "あきらめる(EJDict 側)"])
    let info = try await makeProvider(kaikki: ok(giveUpJsonl)).fetch("give up")
    #expect(info?.meaning == "あきらめる(EJDict 側)")
  }

  @Test("訳語が多い語は打ち切る(必須項目の欄が長大にならないように)")
  func capsMeaningWords() async throws {
    let many = (0..<12).map { #"{"lang_code":"ja","word":"訳\#($0)"}"# }.joined(separator: ",")
    let provider = makeProvider(kaikki: ok(#"{"word":"x","pos":"verb","senses":[],"translations":[\#(many)]}"#))

    let info = try #require(try await provider.fetch("x"))

    #expect(info.meaning.components(separatedBy: " / ").count == 5)
  }

  @Test("対応外の言語の訳語はキャッシュにも訳にも残さない")
  func dropsUnsupportedLanguages() async throws {
    let provider = makeProvider(
      kaikki: ok(
        #"{"word":"x","pos":"verb","senses":[],"translations":[{"lang_code":"de","word":"aufgeben"},{"lang_code":"ja","word":"諦める"}]}"#
      ))

    let info = try #require(try await provider.fetch("x"))

    #expect(info.meaning == "諦める")
    #expect(try await database.dictionaryCacheDao.find("x")?.contains("aufgeben") == false)
  }

  @Test("kaikki・EJDict 両 miss で例文も無ければ nil(未収録)")
  func nothingFoundIsNil() async throws {
    #expect(try await makeProvider().fetch("zzzzz") == nil)
  }

  // kaikki の見出しが入力とずれる句(`run out of` は Wiktionary が `run out`)
  // では、Tatoeba だけが自動入力の出所になる。
  @Test("kaikki・EJDict 両 miss でも Tatoeba に例文があれば返す")
  func tatoebaOnly() async throws {
    let provider = makeProvider(tatoeba: ok(tatoebaHit("We've run out of soap.", "石鹸がないです。")))

    let info = try #require(try await provider.fetch("run out of"))

    #expect(info.exampleEn == "We've run out of soap.")
    #expect(info.exampleTranslation == "石鹸がないです。")
    // 埋まるのは例文だけ。訳が空なので登録フォームは警告バナーを出す。
    #expect(info.meaning == "")
    #expect(info.partsOfSpeech.isEmpty)
  }

  @Test("audioUrl は取得しない(発音は Google 翻訳リンクに一本化)")
  func noAudioUrl() async throws {
    #expect(try await makeProvider(kaikki: ok(kaikkiFixture)).fetch("serendipity")?.audioUrl == "")
  }

  @Test("大文字・空白は正規化してから検索する")
  func normalizesInput() async throws {
    try await seedEjdict(["apple": "リンゴ"])

    let info = try await makeProvider().fetch("  Apple ")

    #expect(info?.word == "apple")
    #expect(info?.meaning == "リンゴ")
  }

  @Test("成功レスポンスはキャッシュされ、2 回目は取得しない")
  func cachesSuccess() async throws {
    let provider = makeProvider(kaikki: ok(kaikkiFixture))

    _ = try await provider.fetch("serendipity")
    _ = try await provider.fetch("serendipity")

    #expect(kaikkiCalls.count == 1)
    // 生の JSONL ではなく、正規化した JSON 配列が入る
    let cached = try #require(try await database.dictionaryCacheDao.find("serendipity"))
    #expect(try KaikkiClient.parseEntries(cached).count == 2)
  }

  // キャッシュは書き出し → 読み込みを通るため、キー名がずれると 2 回目だけ
  // 訳が消える(1 回目は生レスポンスから読むので気付けない)。
  @Test("キャッシュから読んだ 2 回目も kaikki の訳語を返す")
  func cachedTranslationsSurvive() async throws {
    let provider = makeProvider(kaikki: ok(giveUpJsonl))

    _ = try await provider.fetch("give up")
    let second = try await provider.fetch("give up")

    #expect(kaikkiCalls.count == 1)
    #expect(second?.meaning == "降服する / 諦める / やめる")
  }

  @Test("未収録(404)はキャッシュしない")
  func doesNotCacheNotFound() async throws {
    _ = try await makeProvider().fetch("zzzzz")
    #expect(try await database.dictionaryCacheDao.find("zzzzz") == nil)
  }

  // Free Dictionary は common word でも 502 を返すことがあり、当時は
  // 取得失敗で登録フロー全体が失敗していた。EJDict の訳だけでも登録できる。
  @Test("kaikki が 502 でも EJDict がヒットすれば例外を投げず続行する")
  func continuesOnKaikkiFailureWithEjdict() async throws {
    try await seedEjdict(["phrase": "句、成句"])
    let provider = makeProvider(kaikki: { .init(status: 502, body: "bad gateway") })

    let info = try #require(try await provider.fetch("phrase"))

    #expect(info.meaning == "句、成句")
    #expect(info.ipa == "")
  }

  @Test("kaikki が 502 で EJDict も miss なら WordInfoError")
  func throwsOnKaikkiFailureWithoutEjdict() async {
    let provider = makeProvider(kaikki: { .init(status: 502, body: "bad gateway") })
    await #expect(throws: WordInfoError.self) { try await provider.fetch("zzzzz") }
  }

  @Test("DeepL キー未設定なら翻訳を呼ばず exampleTranslation は空")
  func noDeeplWithoutKey() async throws {
    let info = try await makeProvider(kaikki: ok(kaikkiFixture)).fetch("serendipity")

    #expect(deeplCalls.count == 0)
    #expect(info?.exampleTranslation == "")
  }

  @Test("DeepL 失敗(キー不正)でも throw せず exampleTranslation 空で続行する")
  func continuesOnDeeplFailure() async throws {
    let info = try #require(try await makeProvider(kaikki: ok(kaikkiFixture), deeplApiKey: "bad-key").fetch("serendipity"))

    #expect(deeplCalls.count == 1)
    #expect(info.exampleTranslation == "")
    #expect(info.exampleEn == "It was serendipity that brought them together.")
  }

  @Test("繁体字: EJDict は引かず、kaikki の北京語の訳語を繁体字で採る")
  func traditionalChineseMeaning() async throws {
    try await seedEjdict(["achieve": "成し遂げる"])

    let info = try #require(try await makeProvider(kaikki: ok(achieveJsonl), language: .zhHant).fetch("achieve"))

    #expect(info.meaning == "實現 / 達到 / 完成")
    #expect(info.translationLanguage == .zhHant)
  }

  @Test("繁体字: 日本語なら同じキャッシュから日本語の訳語を採る(EJDict 未収録時)")
  func japaneseFromSameCache() async throws {
    let info = try #require(try await makeProvider(kaikki: ok(achieveJsonl)).fetch("achieve"))

    #expect(info.meaning == "達成する")
    #expect(info.translationLanguage == .ja)
  }

  @Test("繁体字: Tatoeba の繁体字の訳を例文の訳にする")
  func traditionalChineseExample() async throws {
    let tatoeba = json([
      "data": [
        [
          "text": "How did you achieve that so quickly?",
          "translations": [["lang": "cmn", "script": "Hant", "text": "你怎麼這麼快就完成了？"]],
        ]
      ]
    ])
    let provider = makeProvider(kaikki: ok(achieveJsonl), tatoeba: ok(tatoeba), language: .zhHant)

    let info = try #require(try await provider.fetch("achieve"))

    #expect(info.exampleEn == "How did you achieve that so quickly?")
    #expect(info.exampleTranslation == "你怎麼這麼快就完成了？")
  }

  @Test("スペイン語: EJDict は引かず、kaikki の訳語をそのまま重複を畳んで採る")
  func spanishMeaning() async throws {
    try await seedEjdict(["achieve": "成し遂げる"])

    let info = try #require(try await makeProvider(kaikki: ok(achieveEsFrJsonl), language: .es).fetch("achieve"))

    #expect(info.meaning == "conseguir / lograr")
    #expect(info.translationLanguage == .es)
  }

  @Test("フランス語は同じキャッシュからフランス語の訳語を採る")
  func frenchMeaning() async throws {
    let info = try #require(try await makeProvider(kaikki: ok(achieveEsFrJsonl), language: .fr).fetch("achieve"))

    #expect(info.meaning == "accomplir / réaliser")
    #expect(info.translationLanguage == .fr)
  }

  @Test("スペイン語: Tatoeba のスペイン語の訳を例文の訳にする")
  func spanishExample() async throws {
    let tatoeba = json([
      "data": [
        [
          "text": "How did you achieve that so quickly?",
          "translations": [
            ["lang": "jpn", "text": "どうやってそんなに早く達成したの?"],
            ["lang": "spa", "text": "¿Cómo lo lograste tan rápido?"],
          ],
        ]
      ]
    ])
    let provider = makeProvider(kaikki: ok(achieveEsFrJsonl), tatoeba: ok(tatoeba), language: .es)

    let info = try #require(try await provider.fetch("achieve"))

    #expect(info.exampleEn == "How did you achieve that so quickly?")
    #expect(info.exampleTranslation == "¿Cómo lo lograste tan rápido?")
  }

  @Test("英語の語義: 除外タグの無い最初の語義を 1 文だけ採る")
  func englishDefinition() async throws {
    try await seedEjdict(["commute": "通勤する"])

    let info = try #require(
      try await makeProvider(kaikki: ok(commuteDefinitionJsonl), language: .enDefinition).fetch("commute"))

    // obsolete を飛ばし、下位の語義はそれ自身(最後の文)を採る。
    // 2 品詞目以降の語義は足さない。EJDict・訳語は使わない。
    #expect(info.meaning == "To reduce the sentence previously given.")
    #expect(info.translationLanguage == .enDefinition)
  }

  @Test("英語の語義: 例文は訳無しで採り、DeepL で訳さない")
  func englishDefinitionExample() async throws {
    let tatoeba = json(["data": [["text": "I commute to work by train every day.", "translations": []]]])
    let provider = makeProvider(
      kaikki: ok(commuteDefinitionJsonl), tatoeba: ok(tatoeba), deeplApiKey: "key", language: .enDefinition)

    let info = try #require(try await provider.fetch("commute"))

    #expect(info.exampleEn == "I commute to work by train every day.")
    #expect(info.exampleTranslation == "")
    #expect(deeplCalls.count == 0)
  }
}
