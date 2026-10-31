import EitangochoData
import Foundation
import Testing

@testable import Eitangocho

/// Flutter 版の test/features/settings/data/settings_notifier_test.dart を移したもの。
/// 「次回読み込みでも復元される」は、同じ UserDefaults から作り直した SettingsStore で確かめる。
@MainActor
final class SettingsStoreTests {
  private let suiteName = "SettingsStoreTests-\(UUID().uuidString)"
  private let defaults: UserDefaults

  init() {
    defaults = UserDefaults(suiteName: suiteName)!
  }

  deinit {
    UserDefaults().removePersistentDomain(forName: suiteName)
  }

  private func makeStore(languages: [String] = ["en-US"]) -> SettingsStore {
    SettingsStore(defaults: defaults, preferredLanguages: languages)
  }

  @Test func 未設定のときは既定値を返す() {
    let settings = makeStore()
    #expect(settings.quizDirection == .enToJa)
    #expect(settings.showIpa)
    #expect(settings.deeplApiKey.isEmpty)
    #expect(settings.uiScale == AppDimensions.defaultUiScale)
    // 学習中カードの既定は 2 列。
    #expect(settings.cardLayout == .twoColumns)
    // 全単語の並びの既定は登録日の新しい順(並び替え導入前と同じ)。
    #expect(settings.wordSortOrder == .newest)
    // 訳の言語は端末の言語から決まる。英語の端末は日本語になる。
    #expect(settings.translationLanguage == .ja)
    #expect(settings.appearance == .light)
  }

  @Test func 訳の言語が未保存なら端末の言語から決めて保存しない() {
    #expect(makeStore(languages: ["zh-Hant-TW"]).translationLanguage == .zhHant)
    #expect(makeStore(languages: ["ko-KR"]).translationLanguage == .enDefinition)
    #expect(defaults.object(forKey: SettingsStore.Key.translationLanguage) == nil)
  }

  @Test func setTranslationLanguageで更新され次回読み込みでも復元される() {
    makeStore().setTranslationLanguage(.zhHant)
    #expect(makeStore().translationLanguage == .zhHant)
    // Flutter 版と同じく enum の名前で保存する(DB の storageCode の zh-Hant ではない)。
    #expect(defaults.string(forKey: "translationLanguage") == "zhHant")
  }

  @Test func setWordSortOrderで更新され次回読み込みでも復元される() {
    let store = makeStore()
    store.setWordSortOrder(.mostCorrect)
    #expect(store.wordSortOrder == .mostCorrect)
    #expect(makeStore().wordSortOrder == .mostCorrect)
  }

  @Test func setCardLayoutで更新され次回読み込みでも復元される() {
    let store = makeStore()
    store.setCardLayout(.oneColumn)
    #expect(store.cardLayout == .oneColumn)
    #expect(makeStore().cardLayout == .oneColumn)
  }

  @Test func setUiScaleは範囲外の値をminとmaxに丸めて保存する() {
    let store = makeStore()
    store.setUiScale(1.3)
    #expect(store.uiScale == 1.3)
    store.setUiScale(99)
    #expect(store.uiScale == AppDimensions.maxUiScale)
    #expect(makeStore().uiScale == AppDimensions.maxUiScale)
  }

  @Test func setQuizDirectionとsetShowIpaとsetDeeplApiKeyで更新される() {
    let store = makeStore()
    store.setQuizDirection(.jaToEn)
    store.setShowIpa(false)
    store.setDeeplApiKey(" my-key ")
    #expect(store.quizDirection == .jaToEn)
    #expect(!store.showIpa)
    // 前後の空白は取り除いて保存する
    #expect(store.deeplApiKey == "my-key")
    let reloaded = makeStore()
    #expect(reloaded.quizDirection == .jaToEn)
    #expect(!reloaded.showIpa)
    #expect(reloaded.deeplApiKey == "my-key")
  }

  @Test func appearanceの既定はライトでsetAppearanceで切り替わり永続化される() {
    let store = makeStore()
    #expect(store.appearance == .light)
    store.setAppearance(.dark)
    #expect(store.appearance == .dark)
    #expect(makeStore().appearance == .dark)
  }

  @Test func Flutter版が保存した値を同じキーと型で読める() {
    // SharedPreferencesAsync は UserDefaults に素のキー名と素の型で書く。
    defaults.set("jaToEn", forKey: "quizDirection")
    defaults.set(false, forKey: "showIpa")
    defaults.set(1.8, forKey: "uiScale")
    defaults.set("oldest", forKey: "wordSortOrder")
    defaults.set("unknownValue", forKey: "appearance")
    let store = makeStore()
    #expect(store.quizDirection == .jaToEn)
    #expect(!store.showIpa)
    #expect(store.uiScale == 1.8)
    #expect(store.wordSortOrder == .oldest)
    // 知らない名前は既定値。
    #expect(store.appearance == .light)
  }
}
