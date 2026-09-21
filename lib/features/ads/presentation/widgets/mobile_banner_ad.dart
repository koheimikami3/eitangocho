import 'dart:math' as math;

import 'package:eitangocho/app/app_route_observer.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/ads/domain/ad_unit_ids.dart';
import 'package:eitangocho/features/ads/presentation/banner_ad_height_notifier.dart';
import 'package:eitangocho/features/ads/presentation/tab_bar_banner_visible_provider.dart';
import 'package:eitangocho/features/ads/presentation/widgets/mobile_ad_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// タブバーの上に常設するアンカー型アダプティブバナー(iOS のみ)。
///
/// 固定の 320x50 ではなく端末幅に合わせたサイズを Google に決めさせる。
/// 高さは読み込みが終わるまで分からないため、確定したら
/// [bannerAdHeightProvider] に流してコンテンツの下余白に反映させる。
///
/// 隠す条件が 2 つある。どちらも [MobileAdSlot] ごとツリーから外して表現する。
/// - シートや全画面遷移に覆われている間([RouteAware])
/// - クイズ結果でレクタングル広告が出ている間([tabBarBannerVisibleProvider])
class MobileBannerAd extends ConsumerStatefulWidget {
  const MobileBannerAd({super.key});

  /// デザインの余白(padding:8px 12px)。高さの計算にも使う。
  static const _verticalPadding = 8.0;
  static const _horizontalPadding = 12.0;

  /// 上境界の太さ([BorderSide] の既定値)。
  static const _borderWidth = 1.0;

  @override
  ConsumerState<MobileBannerAd> createState() => _MobileBannerAdState();
}

class _MobileBannerAdState extends ConsumerState<MobileBannerAd>
    with RouteAware {
  /// 上に別の画面(シート・全画面遷移)が積まれている間は true。
  var _covered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of<void>(context);
    if (route != null) appRouteObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// 上に別の画面が積まれた。登録シートは画面の 88% を覆うため、そのまま
  /// 置いておくと見えていない広告のインプレッションを稼いでしまう。
  @override
  void didPushNext() => setState(() => _covered = true);

  /// 戻ってきたので出し直す。読み込み直しになるが、覆われている間の
  /// インプレッションを避ける方を優先する。
  @override
  void didPopNext() => setState(() => _covered = false);

  /// 広告に渡す幅。シェルが iPad でも [AppDimensions.mobileContentMaxWidth] に
  /// 絞っているため、画面幅ではなくそちらに合わせる(広告だけがはみ出す)。
  int _adWidth(BuildContext context) {
    final available = math.min(
      MediaQuery.sizeOf(context).width,
      AppDimensions.mobileContentMaxWidth,
    );
    return (available - MobileBannerAd._horizontalPadding * 2).truncate();
  }

  @override
  Widget build(BuildContext context) {
    final visible = ref.watch(tabBarBannerVisibleProvider);
    if (_covered || !visible) {
      // 消えている間は下余白も返す。build 中に Provider は変更できないため、
      // フレームの後に回す。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(bannerAdHeightProvider.notifier).update(0);
      });
      return const SizedBox.shrink();
    }
    final palette = context.palette;

    return MobileAdSlot(
      adUnitId: AdUnitIds.tabBarBanner,
      // 常設のこの枠だけ通常サイズのアンカー型アダプティブにする(大型は
      // 端末高の 15% = 実測 118pt あり、常に居座るには大きすぎた)。
      // 通常サイズの API は 8.0.0 で非推奨になったが、Google が用意する
      // 「幅に合わせた小さめのバナー」は現状これだけ。将来削除されたら
      // 固定の AdSize.banner(320x50)か、maxHeight を指定できる
      // getInlineAdaptiveBannerAdSize に移す。
      resolveSize: (context) =>
          // ignore: deprecated_member_use
          AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            _adWidth(context),
          ),
      onSizeChanged: (size) => ref
          .read(bannerAdHeightProvider.notifier)
          .update(
            size == null
                ? 0
                : size.height +
                      MobileBannerAd._verticalPadding * 2 +
                      MobileBannerAd._borderWidth,
          ),
      builder: (context, adView) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: MobileBannerAd._horizontalPadding,
          vertical: MobileBannerAd._verticalPadding,
        ),
        decoration: BoxDecoration(
          color: palette.surfaceHeader,
          border: Border(
            top: BorderSide(
              color: palette.borderAlpha(8),
              width: MobileBannerAd._borderWidth,
            ),
          ),
        ),
        child: adView,
      ),
    );
  }
}
