import Testing

@testable import Eitangocho

/// Flutter 版の test/utils/google_translate_url_test.dart を移したもの。
struct GoogleTranslateURLTests {
  @Test func 単語を埋め込んだGoogle翻訳のURLを作る() {
    #expect(
      GoogleTranslateURL.make("serendipity", language: .ja).absoluteString
        == "https://translate.google.com/?sl=en&tl=ja&text=serendipity&op=translate")
  }

  @Test func 空白と記号は百分率符号化する() {
    #expect(
      GoogleTranslateURL.make("coup d'état", language: .ja).absoluteString
        == "https://translate.google.com/?sl=en&tl=ja&text=coup%20d'%C3%A9tat&op=translate")
  }

  @Test func 訳先は訳の言語に合わせる() {
    #expect(
      GoogleTranslateURL.make("apple", language: .zhHant).absoluteString
        == "https://translate.google.com/?sl=en&tl=zh-TW&text=apple&op=translate")
    #expect(
      GoogleTranslateURL.make("apple", language: .es).absoluteString
        == "https://translate.google.com/?sl=en&tl=es&text=apple&op=translate")
    #expect(
      GoogleTranslateURL.make("apple", language: .fr).absoluteString
        == "https://translate.google.com/?sl=en&tl=fr&text=apple&op=translate")
  }
}
