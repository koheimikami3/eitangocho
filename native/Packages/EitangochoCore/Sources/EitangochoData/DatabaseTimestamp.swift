import Foundation

/// DB の日時列(UNIX 秒の整数)と `Date` の変換。
///
/// drift は DateTime を秒精度の整数で保存する(Flutter 版は build.yaml で
/// 文字列保存に切り替えていない)。GRDB の `Date` の既定は文字列なので使わず、
/// 日時列は必ずここを通す。精度を秒に揃えるのは、同期のマージで
/// 「同時刻なら削除の勝ち」を判定する前提が秒精度だから(WordExportService)。
enum DatabaseTimestamp {
  /// 秒に切り捨てた整数(drift の `millisecondsSinceEpoch ~/ 1000` と同じ)。
  static func seconds(_ date: Date) -> Int64 {
    Int64(date.timeIntervalSince1970.rounded(.down))
  }

  static func date(_ seconds: Int64) -> Date {
    Date(timeIntervalSince1970: TimeInterval(seconds))
  }
}
