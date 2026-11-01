import Foundation

/// 設定の「バージョン」の行に出す値。
enum AppVersion {
  /// 表示用のアプリのバージョン(`2.11.1` の形)。バンドルから取る(定数で持つと上げ忘れる)。
  static let display = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
}
