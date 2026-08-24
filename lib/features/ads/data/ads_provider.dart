import 'package:eitangocho/features/ads/data/tracking_authorizer.dart';
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
  // 広告ユニットが 1 つも配線されていない間は SDK に触れない。GMA SDK は
  // 不正なアプリ ID で初期化すると例外を投げるため、初期化ごと見送る。
  //
  // 購入状態の確認より前に置くのは、出す広告が 1 つも無いときに RevenueCat の
  // 応答を待たずに済ませるため。
  if (!AdUnitIds.hasAnyUnit) {
    adLog('広告ユニット ID が空のため広告を出しません(AdMob 登録待ち)');
    return false;
  }

  // 購入状態は watch ではなく read で見る。確定を待っている最中に購入状態が
  // 流れ込むと、watch では自分自身が無効化されて計算が完了しなくなる
  // (この Provider は購読者を持たないまま `.future` で読まれるため、
  // 中断された計算を待っている呼び出し側が取り残される)。
  //
  // 購入が後から成立したときに広告を止める役目は MobileAdSlot が担う。
  // 表示は build の購入チェックで即座に消え、まだ読み込んでいない枠は
  // _loadAd の入口で止まる。
  //
  // RevenueCat の応答を待ってから先へ進む。理由は 2 つ。
  //
  // ひとつは PurchaseState.proUnlocked の初期値が false で、待たずに読むと
  // Pro 購入者にもトラッキング許可を求めてしまうこと。もうひとつは、課金と
  // ATT の 2 つの SDK が同時にダイアログを出す状況を作らないこと(後から
  // 出そうとした方は黙って出ないまま返る)。
  //
  // 圏外の初回起動では entitlement が取れず永久に待つことになるため上限を
  // 置き、超えたら未購入として進む(広告が出るだけで実害はない)。
  await ref
      .read(purchaseProvider.notifier)
      .proUnlockedKnown
      .timeout(
        const Duration(seconds: 3),
        onTimeout: () => adLog('購入状態を確認できないまま先へ進みます'),
      );

  // Pro を買った人には ATT も聞かず、SDK の初期化もしない。広告を出さない
  // のにトラッキングの許可を求めるのは筋が通らない。
  if (ref.read(purchaseProvider).proUnlocked) {
    adLog('Pro を購入済みのため広告を出しません');
    return false;
  }

  try {
    // ATT はアプリがアクティブになるまで要求されない(TrackingAuthorizer が
    // 待つ)。ダイアログを出せなかった場合もここは戻り、非パーソナライズ
    // 広告として初期化へ進む。出し直しは向こうが引き受ける。
    await ref.read(trackingAuthorizerProvider).ensureRequested();
    final status = await MobileAds.instance.initialize();
    adLog('SDK 初期化完了: ${status.adapterStatuses.keys.join(", ")}');
    return true;
  } catch (error, stackTrace) {
    // 広告が出せなくても単語帳としては使えるべきなので、握って諦める。
    adLog('SDK の初期化に失敗: $error\n$stackTrace');
    return false;
  }
}
