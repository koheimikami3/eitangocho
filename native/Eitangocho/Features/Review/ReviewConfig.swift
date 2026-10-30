import Foundation

/// レビュー依頼を出す条件としきい値と、レビューまわりの公開値(Flutter 版の ReviewConfig)。
///
/// OS のレビュー依頼は年 3 回・アプリ単位の上限があり、ユーザーは設定で無効にもできる。
/// 出せる回数が貴重なので、「達成の直後で、かつ手が空いている瞬間」= クイズを最後まで終えた直後と、
/// 登録単語数の節目の保存直後に絞って出す。
enum ReviewConfig {
  /// App Store のアプリ ID(公開値なのでコードに書く)。iOS / macOS は同じアプリレコードなので 1 つで両方に効く。
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

  /// 1 セッションの最低出題数。1〜2 語のセッションを「達成」と数えないため。
  static let minQuestions = 5

  /// 「覚えている」の最低割合。成績が悪い直後に評価を求めない。
  static let minKnewRatio = 0.6

  /// 依頼するまでに必要な累計クイズ完了回数(今回を含む)。
  static let minQuizCompletions = 3

  /// 依頼するまでに必要な登録単語数。
  static let minWordCount = 20

  /// 登録単語数がちょうどこの数になったとき(単語登録の保存直後)にも依頼する。
  /// そこまで自分で登録した人は使い込んでいて、保存直後は手が空いているため。
  /// クイズの条件とは別の契機で、前回からの間隔(`requestInterval`)だけ共通。
  static let wordCountMilestones: Set<Int> = [50, 100]

  /// 前回の依頼から次に依頼するまでの最短間隔(120 日)。OS の上限(年 3 回)を無駄撃ちしないために置く。
  static let requestInterval: TimeInterval = 120 * 24 * 60 * 60

  /// 契機の画面遷移からレビュー依頼を出すまでの待ち時間。クイズの結果画面への遷移や
  /// 登録後の画面の切り替えが落ち着いてからシステムのシートを重ねる。
  static let promptDelay: Duration = .seconds(1)
}
