import EitangochoSync
import SwiftUI

/// 計測の元になる状態の変化を拾って `AnalyticsReporter` に渡す(起動に成功した後の画面に付ける)。
///
/// Flutter 版は Provider を listen していた。Swift には iOS 18 で使える変化の流れが無いので、
/// RootView が外観を拾うのと同じく `onChange(of:initial:)` で拾う。
struct AnalyticsReporting: ViewModifier {
  let reporter: AnalyticsReporter
  let shell: MainShellModel
  let settings: SettingsStore
  let session: AppModel.Session

  func body(content: Content) -> some View {
    content
      .onChange(of: shell.view, initial: true) { previous, view in
        reporter.reportScreen(view)
        session.quiz.viewChanged(from: previous, to: view)
      }
      .onChange(of: AnalyticsReporter.settingsProperties(settings), initial: true) { _, properties in
        reporter.reportSettings(properties)
      }
      // 初回の読み込みが終わるまでは nil(Flutter 版も一覧の値が届いてから送る)。
      .onChange(of: session.words.isLoaded ? session.words.words.count : nil, initial: true) { _, count in
        if let count { reporter.reportWordCount(count) }
      }
      .onChange(of: session.sync.enabled, initial: true) { _, enabled in
        reporter.reportSyncEnabled(enabled)
      }
  }
}
