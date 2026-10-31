import FirebaseAnalytics
import FirebaseCore
import Foundation
import OSLog
import SwiftUI

/// 計測 SDK の呼び出しを閉じ込める抽象(Flutter 版の AnalyticsClient)。
///
/// SDK の型が `AnalyticsLogger` より上に漏れないようにする。テストではフェイクに差し替える。
/// **計測の失敗でアプリを止めない**(広告・課金・レビューと同じ方針)。
protocol AnalyticsClient {
  func logEvent(_ name: String, parameters: [String: AnyHashable])

  func logScreenView(_ screenName: String)

  /// `value` が nil ならそのプロパティを消す。
  func setUserProperty(_ name: String, value: String?)
}

/// Firebase Analytics による実装。
///
/// configure できたとき(Release ビルドで GoogleService-Info.plist がある)だけ送る。
/// Debug では送らず、送るはずだった内容をログ(カテゴリ analytics)に出して Dev ビルドで確かめられるようにする。
final class FirebaseAnalyticsClient: AnalyticsClient {
  private let enabled: Bool

  private static let logger = Logger(subsystem: "com.kohei.mikami.eitangocho", category: "analytics")

  private init(enabled: Bool) {
    self.enabled = enabled
  }

  /// Firebase を初期化して計測を始める(Flutter 版の initializeAnalytics)。起動時に 1 回だけ呼ぶ。
  ///
  /// SDK の自動収集イベント(first_open / session_start / user_engagement)は初期化だけで始まる。
  /// Debug ビルドでは初期化しない。Debug は Bundle ID に `.dev` が付いた別アプリで、Firebase に
  /// 登録した本番の Bundle ID と食い違ううえ、開発中の起動が本番の計測に混ざるため
  /// (dev 用の Firebase プロジェクトは持たない)。
  static func start() -> FirebaseAnalyticsClient {
    #if DEBUG
      return FirebaseAnalyticsClient(enabled: false)
    #else
      // configure は plist が無いと例外で落ちる。計測できなくても単語帳としては使えるべきなので、
      // 無ければ送らずに続ける。
      guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
        logger.error("GoogleService-Info.plist が無いため計測しない")
        return FirebaseAnalyticsClient(enabled: false)
      }
      FirebaseApp.configure()
      return FirebaseAnalyticsClient(enabled: true)
    #endif
  }

  func logEvent(_ name: String, parameters: [String: AnyHashable]) {
    debugLog("\(name) \(parameters)")
    guard enabled else { return }
    Analytics.logEvent(name, parameters: parameters.isEmpty ? nil : parameters.mapValues(\.base))
  }

  /// Flutter 版(FlutterFire の logScreenView)と同じく screen_name だけを付けて送る。
  func logScreenView(_ screenName: String) {
    debugLog("screen_view {screen_name: \(screenName)}")
    guard enabled else { return }
    Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: screenName])
  }

  func setUserProperty(_ name: String, value: String?) {
    debugLog("user_property \(name)=\(value ?? "nil")")
    guard enabled else { return }
    Analytics.setUserProperty(value, forName: name)
  }

  private func debugLog(_ message: String) {
    #if DEBUG
      Self.logger.info("\(message, privacy: .public)")
    #endif
  }
}

/// 何も送らない実装。環境値の既定で、アプリのルートが Firebase の実装に差し替える。
struct NoopAnalyticsClient: AnalyticsClient {
  func logEvent(_ name: String, parameters: [String: AnyHashable]) {}
  func logScreenView(_ screenName: String) {}
  func setUserProperty(_ name: String, value: String?) {}
}

extension EnvironmentValues {
  /// 画面から独自イベントを送る口。アプリのルートで差し込む(既定は何も送らない)。
  @Entry var analytics = AnalyticsLogger(NoopAnalyticsClient())
}
