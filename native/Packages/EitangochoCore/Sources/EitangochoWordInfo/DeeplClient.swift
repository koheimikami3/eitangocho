import EitangochoData
import Foundation

/// DeepL API Free のクライアント(例文を訳の言語へ訳すのにだけ使う。単語訳には使わない)。
/// 翻訳は補助機能なので、失敗(キー不正・上限超過・ネットワーク)は throw せず
/// nil を返し、呼び出し側は exampleTranslation 空のまま続行する(登録を妨げない)。
public struct DeeplClient: Sendable {
  private let session: URLSession

  public init(session: URLSession) {
    self.session = session
  }

  static let timeout: TimeInterval = 10

  public func translate(_ text: String, apiKey: String, to language: TranslationLanguage) async -> String? {
    guard let targetLang = language.deeplTargetLang else { return nil }
    var request = URLRequest(
      url: URL(string: "https://api-free.deepl.com/v2/translate")!, timeoutInterval: Self.timeout)
    request.httpMethod = "POST"
    request.setValue("DeepL-Auth-Key \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    struct Body: Encodable {
      var text: [String]
      var source_lang: String
      var target_lang: String
    }
    struct Response: Decodable {
      struct Translation: Decodable { var text: String? }
      var translations: [Translation]?
    }
    do {
      request.httpBody = try JSONEncoder().encode(Body(text: [text], source_lang: "EN", target_lang: targetLang))
      let (data, status) = try await HTTP.data(request, session: session)
      guard status == 200 else { return nil }
      return try JSONDecoder().decode(Response.self, from: data).translations?.first?.text
    } catch {
      return nil
    }
  }
}
