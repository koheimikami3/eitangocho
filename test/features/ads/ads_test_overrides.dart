import 'package:eitangocho/features/ads/data/ads_provider.dart';

/// 広告を無効にする Provider の差し替え。
///
/// iOS を装う(`debugDefaultTargetPlatformOverride`)ウィジェットテストでは、
/// 広告枠を含む画面を描いた時点で `adsEnabled` が走り、ATT と広告 SDK の
/// プラグインを呼びに行ってしまう。実行機は macOS でプラグインが無いため
/// 例外になるうえ、ATT がアクティブ化を待つタイマーが残って
/// flutter_test の "pending timer" 検査に引っかかる。
///
/// 広告そのものを検証するテスト以外は、これを overrides に足すこと。
final adsDisabled = adsEnabledProvider.overrideWith((ref) async => false);
