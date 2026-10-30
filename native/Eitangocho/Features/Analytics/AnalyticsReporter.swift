import Foundation

/// ユーザープロパティと主画面の screen_view を送る(Flutter 版の analyticsReporterProvider)。
///
/// 元の状態の変化は `AnalyticsReporting`(画面の修飾子)が拾って渡す。ユーザープロパティは
/// それ以降に送るイベントに付く。値が変わったときだけ送り、単語の追加のたびに同じ区間を送り直さない。
/// 名前と値は Flutter 版と同じ。
final class AnalyticsReporter {
  private let logger: AnalyticsLogger

  /// 送った値。同じ値を送り直さないために持つ。
  private var sent: [String: String?] = [:]

  init(_ logger: AnalyticsLogger) {
    self.logger = logger
    // Android 版を出せば android。
    #if os(macOS)
      setProperty("app_platform", "macos")
    #else
      setProperty("app_platform", "ios")
    #endif
  }

  /// 設定から作るユーザープロパティ。OS ごとの出し分けは Flutter 版と同じ
  /// (表示倍率は macOS だけ、外観とカードの並びは iOS だけ)。
  static func settingsProperties(_ settings: SettingsStore) -> [String: String] {
    var properties = [
      "translation_language": settings.translationLanguage.storageCode,
      "quiz_direction": quizDirectionValue(settings.quizDirection),
      "show_ipa": boolValue(settings.showIpa),
      "word_sort_order": snakeCase(settings.wordSortOrder.rawValue),
    ]
    #if os(macOS)
      properties["ui_scale"] = String(format: "%.1f", settings.uiScale)
    #else
      properties["appearance"] = settings.appearance.rawValue
      properties["card_layout"] = snakeCase(settings.cardLayout.rawValue)
    #endif
    return properties
  }

  func reportSettings(_ properties: [String: String]) {
    for (name, value) in properties {
      setProperty(name, value)
    }
  }

  /// 登録単語数。初回の読み込みが終わる前は呼ばない(0 語と区別がつかないため)。
  func reportWordCount(_ count: Int) {
    setProperty("word_count_bucket", wordCountBucket(count))
  }

  /// 同期の有効 / 無効。Flutter 版は保存値の復元を待ってから送るが、Swift 版の SyncController は
  /// 生成時に保存値を読み終えているので待たない。
  func reportSyncEnabled(_ enabled: Bool) {
    setProperty("sync_enabled", boolValue(enabled))
  }

  func reportScreen(_ view: MainView) {
    logger.logScreenView(screenName(view))
  }

  private func setProperty(_ name: String, _ value: String?) {
    if let previous = sent[name], previous == value { return }
    sent[name] = value
    logger.setUserProperty(name, value: value)
  }
}
