import Foundation

/// 書き出し JSON の日時の文字列。Flutter 版(Dart の DateTime)と読み書きし合える形にする。
///
/// 古い OS の端末は Flutter 版のまま同期し続けるので、この互換は恒久に要る
/// (docs/design.md「データ・同期」)。
enum ExportDate {
  /// Dart の `toUtc().toIso8601String()` と同じ形(`2026-10-29T12:34:56.000Z`)で書く。
  /// ミリ秒未満は切り捨てる(DB の日時は秒精度なので、書き出すのは `.000` ばかり)。
  static func format(_ date: Date) -> String {
    let millisecondsSinceEpoch = (date.timeIntervalSince1970 * 1000).rounded(.down)
    let seconds = (millisecondsSinceEpoch / 1000).rounded(.down)
    let milliseconds = Int(millisecondsSinceEpoch - seconds * 1000)
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    let c = calendar.dateComponents(
      [.year, .month, .day, .hour, .minute, .second], from: Date(timeIntervalSince1970: seconds))
    return String(
      format: "%04d-%02d-%02dT%02d:%02d:%02d.%03dZ",
      c.year!, c.month!, c.day!, c.hour!, c.minute!, c.second!, milliseconds)
  }

  /// Dart の `DateTime.parse` が受け付ける形を読む。
  ///
  /// Dart は小数秒を 6 桁まで書く(`exportedAt` は DateTime.now() なのでマイクロ秒まで付く)。
  /// 時差の表記が無ければ、Dart と同じく端末の時刻として読む。
  static func parse(_ string: String) -> Date? {
    guard let match = string.wholeMatch(of: pattern) else { return nil }
    guard
      let year = Int(match.1), let month = Int(match.2), let day = Int(match.3)
    else { return nil }
    let hour = match.4.flatMap { Int($0) } ?? 0
    let minute = match.5.flatMap { Int($0) } ?? 0
    let second = match.6.flatMap { Int($0) } ?? 0
    // Dart はマイクロ秒より細かい桁を切り捨てる。
    let fraction = match.7.map { digits -> Double in
      let kept = String(digits.prefix(6))
      return (Double(kept) ?? 0) / pow(10, Double(kept.count))
    } ?? 0

    var calendar = Calendar(identifier: .gregorian)
    let zone = match.8.map(String.init)
    calendar.timeZone = zone == nil ? .current : TimeZone(identifier: "UTC")!
    // 範囲外の値(13 月など)は Dart と同じく繰り上げて読む。
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = hour
    components.minute = minute
    components.second = second
    guard let base = calendar.date(from: components) else { return nil }
    return base.addingTimeInterval(fraction - offsetSeconds(zone))
  }

  /// `Z` なら 0、`+09:00` なら 9 時間。
  private static func offsetSeconds(_ zone: String?) -> TimeInterval {
    guard var zone = zone?.trimmingCharacters(in: .whitespaces), !zone.isEmpty,
      zone.uppercased() != "Z"
    else { return 0 }
    let sign: Double = zone.removeFirst() == "-" ? -1 : 1
    let digits = zone.filter(\.isNumber)
    let hours = Double(digits.prefix(2)) ?? 0
    let minutes = Double(digits.dropFirst(2).prefix(2)) ?? 0
    return sign * (hours * 3600 + minutes * 60)
  }

  /// Dart の DateTime.parse の書式(日付だけ・区切りの省略・空白区切りも含む)。
  nonisolated(unsafe) private static let pattern =
    #/([+-]?\d{4,6})-?(\d\d)-?(\d\d)(?:[T ](\d\d)(?::?(\d\d)(?::?(\d\d)(?:[.,](\d+))?)?)?(\s?(?:[zZ]|[+-]\d\d(?::?\d\d)?))?)?/#
}
