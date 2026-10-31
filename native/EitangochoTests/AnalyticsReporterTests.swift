import Foundation
import Testing

@testable import Eitangocho

/// Flutter 版の test/features/analytics/data/analytics_reporter_test.dart を移したもの。
/// 状態の変化を拾う部分(AnalyticsReporting の onChange)は画面側なので、手動の確認に回す。
@MainActor
final class AnalyticsReporterTests {
  private let suiteName = "AnalyticsReporterTests-\(UUID().uuidString)"
  private let defaults: UserDefaults
  private let client = FakeAnalyticsClient()

  init() {
    defaults = UserDefaults(suiteName: suiteName)!
  }

  deinit {
    UserDefaults().removePersistentDomain(forName: suiteName)
  }

  /// 起動直後と同じく、設定・単語数・同期の有効を一通り渡した reporter を返す。
  private func start(wordCount: Int) -> (AnalyticsReporter, SettingsStore) {
    let reporter = AnalyticsReporter(AnalyticsLogger(client))
    let settings = SettingsStore(defaults: defaults, preferredLanguages: ["ja-JP"])
    reporter.reportScreen(.learning)
    reporter.reportSettings(AnalyticsReporter.settingsProperties(settings))
    reporter.reportWordCount(wordCount)
    reporter.reportSyncEnabled(false)
    return (reporter, settings)
  }

  @Test func 設定と単語数をユーザープロパティにする() {
    _ = start(wordCount: 2)
    #expect(client.userProperties["app_platform"] == "macos")
    #expect(client.userProperties["word_count_bucket"] == "1_1-9")
    #expect(client.userProperties["show_ipa"] == "true")
    #expect(client.userProperties["quiz_direction"] == "from_english")
    #expect(client.userProperties["word_sort_order"] == "newest")
    #expect(client.userProperties["sync_enabled"] == "false")
    #expect(client.userProperties["translation_language"] == "ja")
    #expect(client.userProperties["ui_scale"] == "1.5")
    // 外観とカードの並びは iOS だけ(Flutter 版と同じ)。
    #expect(client.userProperties["appearance"] == nil)
    #expect(client.userProperties["card_layout"] == nil)
  }

  @Test func 値が変わったときだけ送り直す() {
    let (reporter, settings) = start(wordCount: 0)
    let before = client.userPropertyCalls

    // 並び順だけを変えると、送り直すのも並び順だけ。単語数も区間が同じなら送らない。
    settings.setWordSortOrder(.alphabetical)
    reporter.reportSettings(AnalyticsReporter.settingsProperties(settings))
    reporter.reportWordCount(0)

    #expect(client.userPropertyCalls == before + 1)
    #expect(client.userProperties["word_sort_order"] == "alphabetical")
  }

  @Test func 主画面を切り替えるたびにscreen_viewを送る() {
    let (reporter, _) = start(wordCount: 0)
    reporter.reportScreen(.allWords)
    #expect(client.eventsNamed("screen_view") == [["screen_name": "learning"], ["screen_name": "all_words"]])
  }
}
