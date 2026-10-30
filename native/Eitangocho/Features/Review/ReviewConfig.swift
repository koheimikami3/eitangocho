import Foundation

/// レビューまわりの公開値(Flutter 版の ReviewConfig)。
///
/// クイズ後のレビュー依頼の条件は Phase 4 で移す。今は設定の「App Store でレビューを書く」が使う値だけを持つ。
enum ReviewConfig {
  /// App Store のアプリ ID(公開値なのでコードに書く)。
  static let appStoreId = "6794990348"

  /// ストアのレビューを書く画面。macOS は Mac App Store アプリで開く
  /// (Flutter 版の in_app_review の openStoreListing と同じ URL)。
  static var writeReviewURL: URL {
    #if os(macOS)
      URL(string: "macappstore://apps.apple.com/app/id\(appStoreId)?action=write-review")!
    #else
      URL(string: "https://apps.apple.com/app/id\(appStoreId)?action=write-review")!
    #endif
  }
}
