import EitangochoData
import Foundation
import Testing

@testable import EitangochoWordInfo

/// Flutter 版の test/features/word_registration/data/deepl_client_test.dart の移植。
struct DeeplClientTests {
  @Test("200 なら translations[0].text を返す。ヘッダとボディも検証")
  func returnsTranslation() async throws {
    let recorder = Recorder()
    let bodies = BodyBox()
    let client = DeeplClient(
      session: StubURLProtocol.session { request, body in
        recorder.append(request)
        bodies.set(body)
        return .init(status: 200, body: #"{"translations":[{"text":"彼は本を読む。"}]}"#)
      })

    let result = await client.translate("He reads a book.", apiKey: "test-key", to: .ja)

    #expect(result == "彼は本を読む。")
    let request = try #require(recorder.requests.first)
    #expect(request.value(forHTTPHeaderField: "Authorization") == "DeepL-Auth-Key test-key")
    #expect(request.httpMethod == "POST")
    let json = try #require(try JSONSerialization.jsonObject(with: bodies.value ?? Data()) as? [String: Any])
    #expect(json["text"] as? [String] == ["He reads a book."])
    #expect(json["source_lang"] as? String == "EN")
    #expect(json["target_lang"] as? String == "JA")
  }

  @Test("403(キー不正)なら nil を返す(throw しない)")
  func forbiddenReturnsNil() async {
    let client = DeeplClient(session: StubURLProtocol.session { _, _ in .init(status: 403, body: "forbidden") })
    #expect(await client.translate("text", apiKey: "bad-key", to: .ja) == nil)
  }

  @Test("ネットワーク例外でも nil を返す(throw しない)")
  func networkErrorReturnsNil() async {
    let client = DeeplClient(session: StubURLProtocol.session { _, _ in throw URLError(.notConnectedToInternet) })
    #expect(await client.translate("text", apiKey: "key", to: .ja) == nil)
  }

  @Test("訳先は訳の言語に合わせる(繁体字は ZH-HANT)")
  func targetFollowsLanguage() async throws {
    let bodies = BodyBox()
    let client = DeeplClient(
      session: StubURLProtocol.session { _, body in
        bodies.set(body)
        return .init(status: 200, body: #"{"translations":[{"text":"他在讀書。"}]}"#)
      })

    _ = await client.translate("He reads a book.", apiKey: "key", to: .zhHant)

    let json = try #require(try JSONSerialization.jsonObject(with: bodies.value ?? Data()) as? [String: Any])
    #expect(json["target_lang"] as? String == "ZH-HANT")
  }
}

final class BodyBox: @unchecked Sendable {
  private let lock = NSLock()
  private var data: Data?
  func set(_ data: Data?) { lock.withLock { self.data = data } }
  var value: Data? { lock.withLock { data } }
}
