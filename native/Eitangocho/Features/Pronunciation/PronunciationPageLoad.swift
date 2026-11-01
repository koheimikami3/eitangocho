import Foundation

/// 発音確認のページの読み込みの状態(iOS の MobilePronunciationSheet が WKWebView の通知から進める)。
///
/// 画面のテストが無いので、状態の移り方だけをここに分けてテストする。
nonisolated struct PronunciationPageLoad: Equatable {
  /// 読み込み中か(面の色で覆ってインジケータを出す)。
  private(set) var isLoading = true
  /// 最初の表示の前に失敗したか(その場で引き直せる画面を出す)。
  private(set) var hasError = false
  /// 一度でも表示できたか。表示できた後の失敗では、残っているページを捨てない。
  private var hasRendered = false

  /// 遷移が始まった。
  mutating func started() {
    isLoading = true
    hasError = false
  }

  /// 遷移が終わり、ページを表示できた。
  mutating func finished() {
    hasRendered = true
    isLoading = false
    hasError = false
  }

  /// 遷移が失敗した。
  mutating func failed(_ error: any Error) {
    // 読み込みの中断(NSURLErrorCancelled)は、遷移が差し替わるたびに通知される(Google 翻訳のリダイレクトでも来る)。
    // 「読み込めなかった」ではないのでエラーにしない(続く遷移の通知で状態が決まる)。
    if (error as NSError).code == NSURLErrorCancelled { return }
    // 覆いは必ず外す。表示できた後なら、後から来た失敗(ページ内の遷移など)で白紙に戻さず元のページを残す。
    isLoading = false
    if !hasRendered { hasError = true }
  }

  /// 失敗の画面から引き直す。
  mutating func reload() {
    hasError = false
    isLoading = true
  }
}
