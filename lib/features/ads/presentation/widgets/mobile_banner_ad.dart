import 'dart:math' as math;

import 'package:eitangocho/app/app_route_observer.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/ads/data/ads_provider.dart';
import 'package:eitangocho/features/ads/domain/ad_unit_ids.dart';
import 'package:eitangocho/features/ads/presentation/banner_ad_height_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// タブバーの上に常設するアンカー型アダプティブバナー(iOS のみ)。
///
/// 固定の 320x50 ではなく端末幅に合わせたサイズを Google に決めさせる。
/// 高さは読み込みが終わるまで分からないため、確定したら
/// [bannerAdHeightProvider] に流してコンテンツの下余白に反映させる。
///
/// 読み込めるまでは枠ごと出さない。先に空の枠を置くと、広告が付かない端末で
/// 下端に意味の無い帯が残るため。
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
  BannerAd? _ad;

  /// 読み込みを二重に走らせないためのフラグ。
  var _requesting = false;

  /// 上に別の画面(シート・全画面遷移)が積まれている間は true。
  var _covered = false;

  @override
  void initState() {
    super.initState();
    // 最初のフレームを描いてから読み込む。ATT のダイアログはアプリが
    // アクティブになる前に要求しても表示されないまま返ってしまう。
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAd());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of<void>(context);
    if (route != null) appRouteObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _ad?.dispose();
    super.dispose();
  }

  /// 上に別の画面が積まれた。登録シートは画面の 88% を覆うため、そのまま
  /// 置いておくと見えていない広告のインプレッションを稼いでしまう。
  @override
  void didPushNext() {
    setState(() => _covered = true);
    _disposeAd();
  }

  /// 戻ってきたので出し直す。読み込み直しになるが、覆われている間の
  /// インプレッションを避ける方を優先する。
  @override
  void didPopNext() {
    setState(() => _covered = false);
    _loadAd();
  }

  void _disposeAd() {
    _ad?.dispose();
    _ad = null;
    ref.read(bannerAdHeightProvider.notifier).update(0);
  }

  Future<void> _loadAd() async {
    if (_ad != null || _requesting || _covered) return;
    _requesting = true;
    try {
      if (!await ref.read(adsEnabledProvider.future)) return;
      if (!mounted || _covered) return;

      final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
        _adWidth(context),
      );
      // 端末に合う高さが無ければ広告そのものを諦める(枠も出さない)。
      if (size == null || !mounted || _covered) return;

      await BannerAd(
        adUnitId: AdUnitIds.banner,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            // 読み込み中に覆われた / 画面から消えたなら出さずに捨てる。
            if (!mounted || _covered) {
              ad.dispose();
              return;
            }
            setState(() => _ad = ad as BannerAd);
            ref
                .read(bannerAdHeightProvider.notifier)
                .update(
                  size.height +
                      MobileBannerAd._verticalPadding * 2 +
                      MobileBannerAd._borderWidth,
                );
          },
          // 在庫切れ・通信断など。次の機会(復帰時)に読み直す。
          onAdFailedToLoad: (ad, error) => ad.dispose(),
        ),
      ).load();
    } finally {
      _requesting = false;
    }
  }

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
    final ad = _ad;
    if (ad == null || _covered) return const SizedBox.shrink();
    final palette = context.palette;

    return Container(
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
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
