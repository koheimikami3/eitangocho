/// レビュー依頼を出す条件としきい値。
///
/// OS のレビュー依頼は年 3 回・アプリ単位のクォータがあり、ユーザーは設定で
/// 無効にもできる。出せる回数が貴重なので、「達成の直後で、かつ手が空いている
/// 瞬間」= クイズを最後まで終えた直後に絞って出す。
abstract final class ReviewConfig {
  /// App Store の数値 ID(`https://apps.apple.com/app/id<ここ>`)。
  ///
  /// **空の間は設定のレビューリンクを出さない。** `AdUnitIds.hasAnyUnit` と
  /// 同じ保険で、ID を用意する前でも「リンクが出ないだけで動く」ビルドになる。
  /// レビュー依頼(requestReview)側は ID を必要としないため、空でも動く。
  ///
  /// iOS / macOS は同じアプリレコード(`com.kohei.mikami.eitangocho`)なので
  /// ID は 1 つで両方に効く。
  static const appStoreId = '6794990348';

  /// 設定にレビューリンクを出せるか。
  static bool get canOpenStoreListing => appStoreId.isNotEmpty;

  /// 1 セッションの最低出題数。1〜2 語のセッションを「達成」と数えないため。
  static const minQuestions = 5;

  /// 「覚えている」の最低割合。成績が悪い直後に評価を求めない。
  static const minKnewRatio = 0.6;

  /// 依頼するまでに必要な累計クイズ完了回数(今回を含む)。
  static const minQuizCompletions = 3;

  /// 依頼するまでに必要な登録単語数。
  static const minWordCount = 20;

  /// 前回の依頼から次に依頼するまでの最短間隔。
  /// OS のクォータ(年 3 回)を無駄撃ちしないために置く。
  static const requestInterval = Duration(days: 120);

  /// 結果画面が出てからレビュー依頼を出すまでの待ち時間。
  /// 画面遷移のアニメーションと、クイズ結果の広告の描画が落ち着いてから
  /// システムのシートを重ねる。
  static const promptDelay = Duration(seconds: 1);
}
