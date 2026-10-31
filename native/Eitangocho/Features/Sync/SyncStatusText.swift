import EitangochoSync
import Foundation

/// 同期の状態の文言(Flutter 版の sync_status_text.dart)。macOS 版 / iOS 版で共通に使う。
enum SyncStatusText {
  /// 「今すぐ同期」行の右端に出す状態。同期が有効なときだけ使う(無効なら行そのものが出ない)。
  /// エラーは長く折り返しが要るため、この文には混ぜず行を分けて赤字で出す(failure)。
  static func status(syncing: Bool, lastSyncedAt: Date?) -> String {
    if syncing { return String(localized: .syncing) }
    guard let lastSyncedAt else { return String(localized: .neverSynced) }
    return String(localized: .lastSynced(format(lastSyncedAt)))
  }

  /// 同期の失敗を伝える文。
  static func failure(_ failure: SyncFailure) -> String {
    switch failure.reason {
    case .noICloud: String(localized: .syncErrorNoICloud)
    case .notCurrent: String(localized: .syncErrorNotCurrent)
    case .unsupportedPlatform: String(localized: .syncErrorUnsupported)
    case .failed: String(localized: .syncErrorFailed(failure.detail ?? ""))
    }
  }

  /// 「2026/07/27 21:45」の形(端末の時刻)。秒までは出さない(1 行の情報量を抑えるため)。
  static func format(_ date: Date, timeZone: TimeZone = .current) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.timeZone = timeZone
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    return formatter.string(from: date)
  }
}
