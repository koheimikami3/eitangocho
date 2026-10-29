import EitangochoData
import Foundation
import Observation

/// アプリ設定。UserDefaults に読み書きし、変更は即保存する。
///
/// キーと型は Flutter 版(SharedPreferencesAsync)と同じ。接頭辞は付いておらず、
/// Bundle ID が同じなので、Flutter 版で保存した設定をそのまま読める
/// (docs/design.md「ネイティブ版(native/)への引き継ぎ」)。
/// enum は名前(rawValue)で保存し、知らない名前は既定値として扱う。
@Observable
final class SettingsStore {
  enum Key {
    static let quizDirection = "quizDirection"
    static let showIpa = "showIpa"
    static let deeplApiKey = "deeplApiKey"
    static let uiScale = "uiScale"
    static let appearance = "appearance"
    static let cardLayout = "cardLayout"
    static let wordSortOrder = "wordSortOrder"
    static let translationLanguage = "translationLanguage"
  }

  private(set) var quizDirection: QuizDirection
  private(set) var showIpa: Bool

  /// DeepL API Free のキー。未設定(空)なら例文の訳をスキップする。
  /// ローカル個人アプリとして平文保存を許容する(確定済みの設計判断)。
  private(set) var deeplApiKey: String

  /// UI 全体の拡大率(macOS 専用。iOS では OS の文字サイズ設定に委ねるため無視する)。
  private(set) var uiScale: Double
  private(set) var appearance: AppAppearance

  /// 学習中カードの並び(1 列 / 2 列)。iOS 専用。
  private(set) var cardLayout: LearningCardLayout

  /// 全単語一覧の並び順。
  private(set) var wordSortOrder: WordSortOrder

  /// 訳の言語。未保存のときは端末の言語から決める(保存はしない)。
  private(set) var translationLanguage: TranslationLanguage

  @ObservationIgnored private let defaults: UserDefaults

  /// `preferredLanguages` は訳の言語が未保存のときの既定を決めるのに使う(テストで差し替える)。
  init(defaults: UserDefaults = .standard, preferredLanguages: [String] = Locale.preferredLanguages) {
    self.defaults = defaults
    func value<T: RawRepresentable>(_ key: String, default fallback: T) -> T where T.RawValue == String {
      defaults.string(forKey: key).flatMap(T.init(rawValue:)) ?? fallback
    }
    quizDirection = value(Key.quizDirection, default: .enToJa)
    showIpa = defaults.object(forKey: Key.showIpa) as? Bool ?? true
    deeplApiKey = defaults.string(forKey: Key.deeplApiKey) ?? ""
    uiScale = defaults.object(forKey: Key.uiScale) as? Double ?? AppDimensions.defaultUiScale
    appearance = value(Key.appearance, default: .light)
    cardLayout = value(Key.cardLayout, default: .twoColumns)
    wordSortOrder = value(Key.wordSortOrder, default: .newest)
    // 未保存なら端末の言語から決め、保存はしない。既存の利用者(日本語の
    // 端末)は ja になり、OS のアプリ別の言語設定を変えたときも追従する。
    translationLanguage = value(
      Key.translationLanguage, default: AppLocale.defaultTranslationLanguage(for: preferredLanguages))
  }

  func setTranslationLanguage(_ language: TranslationLanguage) {
    defaults.set(language.rawValue, forKey: Key.translationLanguage)
    translationLanguage = language
  }

  func setQuizDirection(_ direction: QuizDirection) {
    defaults.set(direction.rawValue, forKey: Key.quizDirection)
    quizDirection = direction
  }

  func setShowIpa(_ value: Bool) {
    defaults.set(value, forKey: Key.showIpa)
    showIpa = value
  }

  func setDeeplApiKey(_ value: String) {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    defaults.set(trimmed, forKey: Key.deeplApiKey)
    deeplApiKey = trimmed
  }

  func setAppearance(_ appearance: AppAppearance) {
    defaults.set(appearance.rawValue, forKey: Key.appearance)
    self.appearance = appearance
  }

  func setCardLayout(_ layout: LearningCardLayout) {
    defaults.set(layout.rawValue, forKey: Key.cardLayout)
    cardLayout = layout
  }

  func setWordSortOrder(_ order: WordSortOrder) {
    defaults.set(order.rawValue, forKey: Key.wordSortOrder)
    wordSortOrder = order
  }

  func setUiScale(_ value: Double) {
    let clamped = min(max(value, AppDimensions.minUiScale), AppDimensions.maxUiScale)
    defaults.set(clamped, forKey: Key.uiScale)
    uiScale = clamped
  }
}
