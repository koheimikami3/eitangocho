import EitangochoData
import Foundation
import Testing

@testable import Eitangocho

/// Flutter 版の test/utils/app_locale_test.dart を移したもの。
struct AppLocaleTests {
  @Test func 日本語の端末は日本語() {
    #expect(AppLocale.resolve(["ja-JP"]) == .ja)
  }

  @Test func 文字体系が_Hant_の中国語は繁体字() {
    #expect(AppLocale.resolve(["zh-Hant-TW"]) == .zhHant)
  }

  @Test func 文字体系の無い_zhTW_zhHK_も繁体字() {
    #expect(AppLocale.resolve(["zh-TW"]) == .zhHant)
    #expect(AppLocale.resolve(["zh-HK"]) == .zhHant)
  }

  @Test func スペイン語とフランス語は地域によらず1つにまとめる() {
    #expect(AppLocale.resolve(["es-MX"]) == .es)
    #expect(AppLocale.resolve(["es-ES"]) == .es)
    #expect(AppLocale.resolve(["fr-CA"]) == .fr)
    #expect(AppLocale.resolve(["fr-FR"]) == .fr)
  }

  @Test func 簡体字は対応言語として扱わず次の候補へ進む() {
    #expect(AppLocale.resolve(["zh-Hans-CN"]) == .en)
    #expect(AppLocale.resolve(["zh-Hans-CN", "ja"]) == .ja)
  }

  @Test func 対応外の言語は英語で優先言語の後ろに対応言語があればそれを採る() {
    #expect(AppLocale.resolve(["ko-KR"]) == .en)
    #expect(AppLocale.resolve(["ko", "ja"]) == .ja)
    #expect(AppLocale.resolve([]) == .en)
  }

  /// 画面の文言は OS が .lproj を選ぶので、その選び方が resolve と一致することを確かめる。
  @Test(arguments: [
    ["ja-JP"], ["en-US"], ["zh-Hant-TW"], ["zh-TW"], ["zh-HK"], ["zh-MO"], ["es-MX"], ["fr-CA"],
    ["zh-Hans-CN"], ["zh-Hans-CN", "ja-JP"], ["ko-KR"], ["ko-KR", "ja-JP"], ["de-DE", "fr-FR"],
  ])
  func OSの言語解決と一致する(preferred: [String]) {
    let available = AppLocale.Language.allCases.map(\.rawValue)
    let resolved = Bundle.preferredLocalizations(from: available, forPreferences: preferred).first
    #expect(resolved == AppLocale.resolve(preferred).rawValue)
  }

  @Test func 訳の言語の既定は画面と同じ言語があればそれで無ければ日本語() {
    #expect(AppLocale.defaultTranslationLanguage(.zhHant) == .zhHant)
    #expect(AppLocale.defaultTranslationLanguage(.es) == .es)
    #expect(AppLocale.defaultTranslationLanguage(.fr) == .fr)
    #expect(AppLocale.defaultTranslationLanguage(.ja) == .ja)
    // 英語の画面(対応外の言語の端末・英語設定の日本語話者)も日本語。
    #expect(AppLocale.defaultTranslationLanguage(.en) == .ja)
  }

  @Test func 対応言語が1つも無いときだけ対応外とみなす() {
    #expect(AppLocale.isUnsupported(["ko-KR"]))
    #expect(AppLocale.isUnsupported(["zh-Hans"]))
    #expect(AppLocale.isUnsupported([]))
    #expect(!AppLocale.isUnsupported(["en-US"]))
    #expect(!AppLocale.isUnsupported(["ko", "ja"]))
  }

  @Test func 対応外の端末の訳の言語の既定は英語の語義で英語の端末は日本語のまま() {
    #expect(AppLocale.defaultTranslationLanguage(for: ["ko-KR"]) == .enDefinition)
    #expect(AppLocale.defaultTranslationLanguage(for: ["en-US"]) == .ja)
    #expect(AppLocale.defaultTranslationLanguage(for: ["fr-CA"]) == .fr)
  }

  @Test func 英語の語義は対応外の端末と選んでいる利用者にだけ選択肢に出す() {
    #expect(AppLocale.translationLanguageChoices(["ko-KR"], current: .ja) == TranslationLanguage.allCases)
    #expect(!AppLocale.translationLanguageChoices(["ja"], current: .ja).contains(.enDefinition))
    #expect(AppLocale.translationLanguageChoices(["ja"], current: .enDefinition).contains(.enDefinition))
  }
}
