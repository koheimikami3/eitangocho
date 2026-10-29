import Foundation
import Testing

@testable import Eitangocho

/// ARB から変換した String Catalog の書式(複数形・位置付きの差し込み)が、
/// Flutter 版と同じ文言になることを確かめる。
struct LocalizableCatalogTests {
  private func resolve(_ resource: LocalizedStringResource, _ language: String) -> String {
    var resource = resource
    resource.locale = Locale(identifier: language)
    return String(localized: resource)
  }

  @Test func 複数形は1のときだけ単数の文言になる() {
    #expect(resolve(.wordCount(1), "en") == "1 word")
    #expect(resolve(.wordCount(3), "en") == "3 words")
    #expect(resolve(.correctCount(1), "en") == "Remembered once")
    #expect(resolve(.wordCount(3), "ja") == "3語")
  }

  @Test func 差し込みが2つある文言は言語ごとの位置に入る() {
    #expect(resolve(.quizSummary(4, 1), "ja") == "覚えている 4語 / 忘れていた 1語")
    #expect(resolve(.quizSummary(4, 1), "en") == "Remembered 4 / Forgot 1")
  }

  @Test func select_は値ごとのキーに分かれる() {
    #expect(resolve(.translationLanguageNameZhHant, "zh-Hant") == "繁體中文")
    #expect(resolve(.fieldMeaning("日本語"), "ja") == "日本語訳 *")
  }
}
