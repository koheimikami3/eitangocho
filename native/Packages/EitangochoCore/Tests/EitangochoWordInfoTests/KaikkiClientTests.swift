import Foundation
import Testing

@testable import EitangochoWordInfo

/// 実レスポンス(kaikki.org の monster)から必要な形だけ抜き出した JSONL。
/// 1 行 1 品詞で、sounds には ipa を持たない要素(audio / rhymes)も混ざる。
let monsterJsonl = """
  {"word":"monster","pos":"noun","sounds":[{"tags":["Received-Pronunciation"],"ipa":"/ˈmɒnstə(ɹ)/"},{"ipa":"/ˈmɑnstɚ/","tags":["US"]},{"audio":"en-us-monster.ogg","tags":["US"]},{"rhymes":"-ɒnstə(ɹ)"}],"senses":[{"examples":[{"text":"The Loch Ness monster is a legend.","type":"example"},{"text":"a monster of a wave — Some Author, 1890","type":"quotation"},{"text":"monster truck","type":"example","tags":["collocation"]}]}]}
  {"word":"monster","pos":"adj","sounds":[],"senses":[{"examples":[{"text":"They had a monster hit last year.","type":"example"}]}]}

  """

/// Flutter 版の test/features/word_registration/data/kaikki_api_client_test.dart の移植。
struct KaikkiClientTests {
  /// 呼ばれた URL のパス(パーセントエンコードのまま)を記録しつつ、パスごとにレスポンスを返す。
  private func makeClient(_ respond: @escaping @Sendable (String) -> StubURLProtocol.Response)
    -> (client: KaikkiClient, recorder: Recorder)
  {
    let recorder = Recorder()
    let client = KaikkiClient(
      session: StubURLProtocol.session { request, _ in
        recorder.append(request)
        return respond(request.url!.path(percentEncoded: true))
      })
    return (client, recorder)
  }

  private func paths(_ recorder: Recorder) -> [String] {
    recorder.requests.map { $0.url!.path(percentEncoded: true) }
  }

  @Test("JSONL を品詞ごとのエントリにパースする")
  func parsesEntries() async throws {
    let (client, recorder) = makeClient { _ in .init(status: 200, body: monsterJsonl) }

    let json = try #require(try await client.fetchEntriesJson("monster"))
    let entries = try KaikkiClient.parseEntries(json)

    #expect(entries.map(\.pos) == ["noun", "adj"])
    #expect(paths(recorder) == ["/dictionary/English/meaning/m/mo/monster.jsonl"])
  }

  @Test("ipa を持たない sounds 要素があってもパースできる")
  func toleratesSoundsWithoutIpa() async throws {
    let (client, _) = makeClient { _ in .init(status: 200, body: monsterJsonl) }

    let entries = try KaikkiClient.parseEntries(try #require(try await client.fetchEntriesJson("monster")))

    #expect(entries[0].sounds.compactMap(\.ipa) == ["/ˈmɒnstə(ɹ)/", "/ˈmɑnstɚ/"])
    #expect(entries[0].sounds.first { $0.tags.contains("US") }?.ipa == "/ˈmɑnstɚ/")
  }

  // 引用は長文でキャッシュを膨らませるだけなので保存段階で落とす。
  @Test("quotation の例文は捨て、example だけ残す")
  func dropsQuotations() async throws {
    let (client, _) = makeClient { _ in .init(status: 200, body: monsterJsonl) }

    let entries = try KaikkiClient.parseEntries(try #require(try await client.fetchEntriesJson("monster")))

    let texts = entries[0].senses.flatMap(\.examples).map(\.text)
    #expect(texts == ["The Loch Ness monster is a legend.", "monster truck"])
  }

  @Test("zh で来る北京語の訳語は cmn に揃えて残し、閩南語などは捨てる")
  func normalizesMandarin() async throws {
    let (client, _) = makeClient { _ in
      .init(
        status: 200,
        body: """
          {"word":"apple","pos":"noun","translations":[\
          {"lang":"Chinese","lang_code":"zh","word":"蘋果 /苹果","tags":["Hokkien"]},\
          {"lang":"Chinese Mandarin","lang_code":"zh","word":"蘋果 /苹果"},\
          {"lang":"Chinese Mandarin","lang_code":"cmn","word":"預訂 /预订"},\
          {"lang":"Chinese Cantonese","lang_code":"yue","word":"蘋果 /苹果"}]}
          """)
    }

    let json = try #require(try await client.fetchEntriesJson("apple"))
    let translations = try KaikkiClient.parseEntries(json)[0].translations

    #expect(translations.map(\.langCode) == ["cmn", "cmn"])
    #expect(translations.map(\.word) == ["蘋果 /苹果", "預訂 /预订"])
    // 言語名は見分けるためだけに読み、キャッシュには書き出さない
    #expect(!json.contains("Chinese Mandarin"))
  }

  // 英語の語義(TranslationLanguage.enDefinition)に使うため、保存段階で落とさない。
  @Test("語義の文とタグをキャッシュに残す")
  func keepsGlossesAndTags() async throws {
    let (client, _) = makeClient { _ in
      .init(
        status: 200,
        body: #"{"word":"thrive","pos":"verb","senses":[{"glosses":["To grow vigorously."],"#
          + #""tags":["intransitive"]},{"glosses":["To prosper."],"tags":["obsolete"]}]}"#)
    }

    let senses = try KaikkiClient.parseEntries(try #require(try await client.fetchEntriesJson("thrive")))[0].senses

    #expect(senses[0].glosses == ["To grow vigorously."])
    #expect(senses[0].tags == ["intransitive"])
    #expect(senses[1].tags == ["obsolete"])
  }

  @Test("大文字小文字を区別するため、404 なら頭大文字で引き直す")
  func retriesCapitalized() async throws {
    let (client, recorder) = makeClient { path in
      path.hasSuffix("/S/Se/September.jsonl")
        ? .init(
          status: 200, body: #"{"word":"September","pos":"noun","sounds":[{"ipa":"/sɛpˈtɛmbə/"}],"senses":[]}"#)
        : .init(status: 404, body: "not found")
    }

    let json = try #require(try await client.fetchEntriesJson("september"))

    #expect(try KaikkiClient.parseEntries(json)[0].word == "September")
    #expect(
      paths(recorder) == [
        "/dictionary/English/meaning/s/se/september.jsonl",
        "/dictionary/English/meaning/S/Se/September.jsonl",
      ])
  }

  @Test("小文字・大文字とも 404 なら未収録(nil)")
  func bothNotFoundIsNil() async throws {
    let (client, recorder) = makeClient { _ in .init(status: 404, body: "not found") }

    #expect(try await client.fetchEntriesJson("asdfghjkl") == nil)
    #expect(recorder.count == 2)
  }

  @Test("1 文字の単語もパスを組める")
  func singleCharacterPath() async throws {
    let (client, recorder) = makeClient { _ in .init(status: 200, body: #"{"word":"a","pos":"article","senses":[]}"#) }

    _ = try await client.fetchEntriesJson("a")

    #expect(paths(recorder) == ["/dictionary/English/meaning/a/a/a.jsonl"])
  }

  // 句動詞は見出しに空白を含むが、kaikki の 2 文字プレフィックスも空白込みの
  // 規則(/a/a%20/a%20la%20carte.jsonl)なので、単語と同じ組み立てでよい。
  @Test("句動詞のパスは空白込みで組む")
  func phrasePath() async throws {
    let (client, recorder) = makeClient { _ in .init(status: 200, body: #"{"word":"give up","pos":"verb","senses":[]}"#) }

    _ = try await client.fetchEntriesJson("give up")

    #expect(paths(recorder) == ["/dictionary/English/meaning/g/gi/give%20up.jsonl"])
  }

  @Test("壊れた行はその行だけ捨てて続行する")
  func skipsBrokenLines() async throws {
    let (client, _) = makeClient { _ in
      .init(status: 200, body: "これは JSON ではない\n{\"word\":\"monster\",\"pos\":\"noun\",\"senses\":[]}\n")
    }

    let entries = try KaikkiClient.parseEntries(try #require(try await client.fetchEntriesJson("monster")))

    #expect(entries.map(\.pos) == ["noun"])
  }

  @Test("型の違う項目は空として読む(必須にしない)")
  func toleratesWrongTypes() async throws {
    let (client, _) = makeClient { _ in
      .init(status: 200, body: #"{"word":"x","pos":"noun","sounds":null,"senses":{"a":1},"translations":[1,{"lang_code":"ja","word":"訳"}]}"#)
    }

    let entry = try KaikkiClient.parseEntries(try #require(try await client.fetchEntriesJson("x")))[0]

    #expect(entry.sounds.isEmpty)
    #expect(entry.senses.isEmpty)
    #expect(entry.translations.map(\.word) == ["訳"])
  }

  @Test("本文が空なら未収録(nil)")
  func emptyBodyIsNil() async throws {
    let (client, _) = makeClient { _ in .init(status: 200, body: "") }
    #expect(try await client.fetchEntriesJson("monster") == nil)
  }

  @Test("502 は WordInfoError")
  func badGatewayThrows() async {
    let (client, _) = makeClient { _ in .init(status: 502, body: "bad gateway") }
    await #expect(throws: WordInfoError.self) { try await client.fetchEntriesJson("monster") }
  }

  @Test("User-Agent を名乗る")
  func sendsUserAgent() async throws {
    let (client, recorder) = makeClient { _ in .init(status: 200, body: monsterJsonl) }

    _ = try await client.fetchEntriesJson("monster")

    let userAgent = recorder.requests.first?.value(forHTTPHeaderField: "User-Agent") ?? ""
    #expect(userAgent.contains("eitangocho"))
  }

  @Test("キャッシュの形は Flutter 版(toJson)と同じキーで、Flutter 版が書いたものも読める")
  func cacheFormatMatchesFlutter() throws {
    // Flutter 版の KaikkiEntry.toJson が書く形(null も書く)。
    let flutterCache = """
      [{"word":"give up","pos":"verb","sounds":[{"ipa":null,"tags":[]}],"senses":[{"glosses":["To surrender."],\
      "tags":[],"examples":[{"text":"I give up!","type":"example","tags":[]}]}],\
      "translations":[{"word":"諦める","lang_code":"ja"}]}]
      """
    let entries = try KaikkiClient.parseEntries(flutterCache)
    #expect(entries[0].translations[0].langCode == "ja")
    #expect(entries[0].senses[0].examples[0].text == "I give up!")

    let reencoded = String(decoding: try JSONEncoder().encode(entries), as: UTF8.self)
    #expect(reencoded.contains(#""lang_code":"ja""#))
    #expect(try KaikkiClient.parseEntries(reencoded) == entries)
  }
}
