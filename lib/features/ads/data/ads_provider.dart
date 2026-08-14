import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:eitangocho/features/ads/domain/ad_log.dart';
import 'package:eitangocho/features/ads/domain/ad_unit_ids.dart';
import 'package:eitangocho/features/purchase/data/purchase_notifier.dart';
import 'package:eitangocho/utils/app_platform.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ads_provider.g.dart';

/// 広告を表示してよいか。true を返した時点で広告 SDK は初期化済み。
///
/// 広告の出し分けはこの真偽値 1 点に集約する。
///
/// keepAlive にするのは、バナーがツリーから外れる(シート表示中など)たびに
/// SDK の初期化と ATT の確認をやり直さないため。
@Riverpod(keepAlive: true)
Future<bool> adsEnabled(Ref ref) async {
  // 広告は iOS のみ。macOS はプラグインが無く、呼べば MissingPluginException。
  if (!AppPlatform.isIOS) return false;
  // Pro を買った人には ATT も聞かず、SDK の初期化もしない。広告を出さない
  // のにトラッキングの許可を求めるのは筋が通らない。
  //
  // 購入が後から成立した場合(この Provider が false を返す前に買った場合を
  // 含む)は、読み込み済みの広告を MobileAdSlot 側が破棄する。
  if (ref.watch(purchaseProvider).proUnlocked) {
    adLog('Pro を購入済みのため広告を出しません');
    return false;
  }
  // 広告ユニットが 1 つも配線されていない間は SDK に触れない。GMA SDK は
  // 不正なアプリ ID で初期化すると例外を投げるため、初期化ごと見送る。
  if (!AdUnitIds.hasAnyUnit) {
    adLog('広告ユニット ID が空のため広告を出しません(AdMob 登録待ち)');
    return false;
  }

  try {
    // ATT の応答が返らないまま止まっても広告自体は出せる(パーソナライズ
    // されないだけ)。アプリがまだアクティブでないうちに要求すると応答が
    // 返らないことがあるため、待ち続けずに先へ進む。
    await _requestTrackingAuthorizationIfNeeded().timeout(
      const Duration(seconds: 5),
      onTimeout: () => adLog('ATT の応答が無いまま初期化へ進みます'),
    );
    final status = await MobileAds.instance.initialize();
    adLog('SDK 初期化完了: ${status.adapterStatuses.keys.join(", ")}');
    return true;
  } catch (error, stackTrace) {
    // 広告が出せなくても単語帳としては使えるべきなので、握って諦める。
    adLog('SDK の初期化に失敗: $error\n$stackTrace');
    return false;
  }
}

/// ATT(トラッキング許可)をまだ聞いていないときだけ 1 回求める。
///
/// 応答の内容は見ない。拒否されてもパーソナライズされない広告は出せるため。
/// SDK の初期化より先に済ませるのは、初期化後に IDFA の利用可否が変わっても
/// その回のリクエストには反映されないため。
Future<void> _requestTrackingAuthorizationIfNeeded() async {
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  adLog('ATT の現在の状態: ${status.name}');
  if (status != TrackingStatus.notDetermined) return;
  final answer = await AppTrackingTransparency.requestTrackingAuthorization();
  adLog('ATT の応答: ${answer.name}');
}
