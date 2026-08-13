import 'package:flutter/foundation.dart';

/// AdMob の広告ユニット ID。
///
/// 広告 ID をコードに直書きしているのは、DeepL の API キーと性質が違うため。
/// 広告 ID は AdMob の管理画面が発行する公開値で、秘匿する意味も、設定画面から
/// 入力させる意味も無い(実際に配信されるアプリはバンドル ID で照合される)。
abstract final class AdUnitIds {
  /// タブバーの上に出すアンカー型アダプティブバナー。
  ///
  /// debug は Google 公式のテスト ID を使う。開発中に本番ユニットを叩くと
  /// 無効なトラフィックとみなされ、AdMob アカウントごと停止されうるため。
  static String get banner => kDebugMode ? _testBanner : _releaseBanner;

  /// iOS のアンカー型アダプティブバナー用のテスト ID(Google 公式)。
  static const _testBanner = 'ca-app-pub-3940256099942544/2435281174';

  /// TODO: AdMob でバナーユニットを作成したら本番の ID に差し替える。
  /// 空の間は広告 SDK の初期化ごと見送る(ads_provider.dart)。
  static const _releaseBanner = '';
}
