import EitangochoData
import Foundation
import Testing

@testable import EitangochoWordInfo

/// 実レスポンスの形。translations は `trans:lang` 指定時のみ入る平坦な配列で、
/// 指定しないと null になる。
func tatoebaResponse(_ sentences: [(String, String?)]) -> String {
  let data: [[String: Any]] = sentences.map { text, ja in
    ["text": text, "lang": "eng", "translations": ja.map { [["lang": "jpn", "text": $0]] } ?? NSNull()]
  }
  return String(decoding: try! JSONSerialization.data(withJSONObject: ["data": data]), as: UTF8.self)
}

func json(_ object: Any) -> String {
  String(decoding: try! JSONSerialization.data(withJSONObject: object), as: UTF8.self)
}

/// Flutter 版の test/features/word_registration/data/tatoeba_api_client_test.dart の移植。
struct TatoebaClientTests {
  private func makeClient(_ respond: @escaping @Sendable () throws -> StubURLProtocol.Response)
    -> (client: TatoebaClient, recorder: Recorder)
  {
    let recorder = Recorder()
    let client = TatoebaClient(
      session: StubURLProtocol.session { request, _ in
        recorder.append(request)
        return try respond()
      })
    return (client, recorder)
  }

  private func query(_ request: URLRequest?) -> [String: String] {
    let items = URLComponents(url: request!.url!, resolvingAgainstBaseURL: false)?.queryItems ?? []
    return Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })
  }

  @Test("訳付きの文を英日ペアで返す")
  func returnsPair() async throws {
    let (client, _) = makeClient { .init(status: 200, body: tatoebaResponse([("Tom obtained a gun.", "トムは銃を手に入れた。")])) }

    let example = try #require(await client.findExample("obtain", language: .ja))

    #expect(example == ExampleSentence(en: "Tom obtained a gun.", translation: "トムは銃を手に入れた。"))
  }

  @Test("必要なクエリを組み立てる(sort が無いと 400 になる)")
  func buildsQuery() async {
    let (client, recorder) = makeClient { .init(status: 200, body: tatoebaResponse([])) }

    _ = await client.findExample("obtain", language: .ja)

    let url = recorder.requests.first?.url
    #expect(url?.host == "api.tatoeba.org")
    #expect(url?.path == "/unstable/sentences")
    #expect(
      query(recorder.requests.first)
        == ["lang": "eng", "q": "obtain", "trans:lang": "jpn", "sort": "relevance", "limit": "30"])
  }

  // 最短だけで選ぶと monster に「Monster!」が付いてしまう。
  @Test("下限に満たない文より、下限以上の文を優先する")
  func prefersMinimumWords() async {
    let (client, _) = makeClient {
      .init(
        status: 200,
        body: tatoebaResponse([
          ("Monster!", "化け物！"),
          ("There's a monster in my closet.", "押し入れに怪物がいる。"),
          ("I saw a monster in the woods last night.", "昨夜森で怪物を見た。"),
        ]))
    }

    #expect(await client.findExample("monster", language: .ja)?.en == "There's a monster in my closet.")
  }

  // 語数で足切りすると、短文しか無い語で訳付きの例文を丸ごと失う。
  @Test("下限以上の候補が無ければ、短い中でいちばん語数の多い文に降りる")
  func fallsBackToLongestShort() async {
    let (client, _) = makeClient {
      .init(status: 200, body: tatoebaResponse([("Ghosts!", "幽霊だ！"), ("Ghosts exist.", "幽霊は存在する。")]))
    }

    #expect(await client.findExample("ghost", language: .ja)?.en == "Ghosts exist.")
  }

  @Test("下限を満たす中では最短の文を選ぶ")
  func picksShortestQualified() async {
    let (client, _) = makeClient {
      .init(
        status: 200,
        body: tatoebaResponse([
          ("Tom obtained a firearm from the shop in town yesterday.", "トムは昨日町の店で銃を買った。"),
          ("How much money have you obtained?", "あなたはどれくらいのお金を手にしましたか。"),
        ]))
    }

    #expect(await client.findExample("obtain", language: .ja)?.en == "How much money have you obtained?")
  }

  // 下限は語数で見ているので、長短の比較も語数で揃える。
  @Test("長短は文字数ではなく語数で比べる")
  func comparesByWordCount() async {
    let (client, _) = makeClient {
      .init(
        status: 200,
        body: tatoebaResponse([
          // 4 語だが 40 文字(文字数で比べるとこちらが最長になる)
          ("Apples contain considerable antioxidants.", "りんごには相当量の抗酸化物質が含まれる。"),
          // 5 語 20 文字
          ("I want an apple now.", "りんごが今すぐ欲しい。"),
        ]))
    }

    // どちらも下限に届かないので降格し、語数の多い方を採る。
    #expect(await client.findExample("apple", language: .ja)?.en == "I want an apple now.")
  }

  // Tatoeba の検索はステミングするため、これを弾けないと別の単語の例文が入る。
  @Test("見出し語の派生語しか含まない文は採用しない")
  func rejectsDerivedWords() async {
    let (client, _) = makeClient {
      .init(
        status: 200,
        body: tatoebaResponse([
          ("I'm displeased with your negligence.", "僕は君の怠慢が気に入らない。"),
          ("He was negligent of his duties.", "彼は職務怠慢だった。"),
        ]))
    }

    #expect(await client.findExample("negligible", language: .ja) == nil)
  }

  @Test("句動詞は語順が変わった文も採用する")
  func acceptsReorderedPhrase() async {
    let (client, _) = makeClient {
      .init(
        status: 200,
        body: tatoebaResponse([("He put on a coat.", "彼はコートを着た。"), ("The wedding was put off.", "結婚式は延期された。")]))
    }

    #expect(await client.findExample("put off", language: .ja)?.en == "The wedding was put off.")
  }

  @Test("訳が無い文は採用しない")
  func requiresTranslation() async {
    let (client, _) = makeClient {
      .init(
        status: 200,
        body: tatoebaResponse([("Tom obtained a gun.", nil), ("Tom obtained a firearm.", "トムは銃を手に入れた。")]))
    }

    #expect(await client.findExample("obtain", language: .ja)?.en == "Tom obtained a firearm.")
  }

  @Test("ヒットしなければ nil")
  func noHitIsNil() async {
    let (client, _) = makeClient { .init(status: 200, body: tatoebaResponse([])) }
    #expect(await client.findExample("zzzzz", language: .ja) == nil)
  }

  // 例文は補助情報なので、失敗しても登録フローを止めない。
  @Test("通信失敗・非 200・壊れたレスポンスはすべて nil")
  func failuresAreNil() async {
    let serverError = makeClient { .init(status: 500, body: "error") }.client
    #expect(await serverError.findExample("obtain", language: .ja) == nil)

    let broken = makeClient { .init(status: 200, body: "not json") }.client
    #expect(await broken.findExample("obtain", language: .ja) == nil)

    let throwing = makeClient { throw URLError(.notConnectedToInternet) }.client
    #expect(await throwing.findExample("obtain", language: .ja) == nil)
  }

  @Test("空文字は問い合わせない")
  func emptyWordDoesNotRequest() async {
    let (client, recorder) = makeClient { .init(status: 200, body: tatoebaResponse([])) }

    #expect(await client.findExample("  ", language: .ja) == nil)
    #expect(recorder.count == 0)
  }

  /// cmn には繁体字と簡体字の訳が混ざって返る(script で区別される)。
  private let chineseResponse = json([
    "data": [
      [
        "text": "They achieved their goal.", "lang": "eng",
        "translations": [["lang": "cmn", "script": "Hans", "text": "他们达到了目标。"]],
      ],
      [
        "text": "How did you achieve that so quickly?", "lang": "eng",
        "translations": [
          ["lang": "cmn", "script": "Hans", "text": "你怎么这么快就完成了？"],
          ["lang": "cmn", "script": "Hant", "text": "你怎麼這麼快就完成了？"],
        ],
      ],
    ]
  ])

  @Test("繁体字: cmn の訳を求め、繁体字の訳がある文だけを採る")
  func traditionalChinese() async throws {
    let body = chineseResponse
    let (client, recorder) = makeClient { .init(status: 200, body: body) }

    let example = try #require(await client.findExample("achieve", language: .zhHant))

    #expect(query(recorder.requests.first)["trans:lang"] == "cmn")
    #expect(example == ExampleSentence(en: "How did you achieve that so quickly?", translation: "你怎麼這麼快就完成了？"))
  }

  @Test("繁体字: 日本語の訳しか無い文は採らない")
  func traditionalChineseRejectsJapanese() async {
    let (client, _) = makeClient { .init(status: 200, body: tatoebaResponse([("Tom obtained a gun.", "トムは銃を手に入れた。")])) }
    #expect(await client.findExample("obtain", language: .zhHant) == nil)
  }

  @Test("スペイン語は spa の訳を求め、文字体系では絞らない")
  func spanish() async {
    let body = json([
      "data": [
        [
          "text": "How did you achieve that so quickly?", "lang": "eng",
          "translations": [["lang": "spa", "script": NSNull(), "text": "¿Cómo lo lograste tan rápido?"]],
        ]
      ]
    ])
    let (client, recorder) = makeClient { .init(status: 200, body: body) }

    let example = await client.findExample("achieve", language: .es)

    #expect(query(recorder.requests.first)["trans:lang"] == "spa")
    #expect(example?.translation == "¿Cómo lo lograste tan rápido?")
  }

  // 英語の語義では例文の訳を持たないので、訳の有無で絞らない。
  @Test("英語の語義は trans:lang を付けず、訳の無い英文も採って訳を空にする")
  func englishDefinition() async throws {
    let body = json([
      "data": [["text": "The plants thrive in this warm, humid climate.", "lang": "eng", "translations": []]]
    ])
    let (client, recorder) = makeClient { .init(status: 200, body: body) }

    let example = try #require(await client.findExample("thrive", language: .enDefinition))

    #expect(query(recorder.requests.first)["trans:lang"] == nil)
    #expect(example == ExampleSentence(en: "The plants thrive in this warm, humid climate.", translation: ""))
  }
}
