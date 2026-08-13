import 'package:flutter/foundation.dart';

/// AdMob の広告ユニット ID。配置ごとに 1 つ作る。
///
/// 広告 ID をコードに直書きしているのは、DeepL の API キーと性質が違うため。
/// 広告 ID は AdMob の管理画面が発行する公開値で、秘匿する意味も、設定画面から
/// 入力させる意味も無い(実際に配信されるアプリはバンドル ID で照合される)。
///
/// 配置ごとに分けるのは、レポート・自動更新の間隔・eCPM の下限・配信停止が
/// すべてユニット単位だから。1 つを使い回すと、どの枠が稼いでいるのか後から
/// 分けられない。
abstract final class AdUnitIds {
  /// タブバーの上に常設するアンカー型アダプティブバナー。
  static String get tabBarBanner =>
      kDebugMode ? _testBanner : _releaseTabBarBanner;

  /// 登録シート・編集シートの最下部に出すアンカー型アダプティブバナー。
  static String get sheetBanner =>
      kDebugMode ? _testBanner : _releaseSheetBanner;

  /// クイズ結果に出す 300x250 レクタングル。
  static String get quizRectangle =>
      kDebugMode ? _testRectangle : _releaseQuizRectangle;

  /// 1 つでも配線済みのユニットがあるか。全部空なら SDK にも触れない。
  static bool get hasAnyUnit =>
      tabBarBanner.isNotEmpty ||
      sheetBanner.isNotEmpty ||
      quizRectangle.isNotEmpty;

  /// debug は Google 公式のテスト ID を使う。開発中に本番ユニットを叩くと
  /// 無効なトラフィックとみなされ、AdMob アカウントごと停止されうるため。
  static const _testBanner = 'ca-app-pub-3940256099942544/2435281174';
  static const _testRectangle = 'ca-app-pub-3940256099942544/2934735716';

  /// 本番の ID。AdMob の「バナー(タブバー上)」ユニット。
  static const _releaseTabBarBanner = 'ca-app-pub-3768273762534884/2278462321';

  /// AdMob の「バナー(登録シート)」ユニット。
  static const _releaseSheetBanner = 'ca-app-pub-3768273762534884/5497904061';

  /// AdMob の「レクタングル(クイズ結果)」ユニット。
  static const _releaseQuizRectangle =
      'ca-app-pub-3768273762534884/2121765839';
}
