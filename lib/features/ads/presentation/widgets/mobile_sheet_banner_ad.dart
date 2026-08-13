import 'dart:math' as math;

import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/ads/domain/ad_unit_ids.dart';
import 'package:eitangocho/features/ads/presentation/widgets/mobile_ad_slot.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 登録シート・編集シートの最下部に固定するバナー(iOS のみ)。
///
/// [MobileSheet] の `footer` に渡す。スクロール領域の外側に置くのは
/// デザインどおり(`flex-shrink:0`)。下の余白だけタブバー上のバナーより
/// 厚い(22px)のは、シートの下端がホームインジケータに接するため。
///
/// **キーボードが出ている間は出さない**。シートはキーボードの分だけ持ち上がる
/// ので、そのまま置くと入力欄とキーボードの間に広告が挟まる。誤タップは
/// AdMob のポリシー違反(無効なクリック)になりうるため、隠す方を取る。
class MobileSheetBannerAd extends StatelessWidget {
  const MobileSheetBannerAd({super.key});

  /// デザインの余白(padding:8px 12px 22px)。
  static const _topPadding = 8.0;
  static const _bottomPadding = 22.0;
  static const _horizontalPadding = 12.0;

  @override
  Widget build(BuildContext context) {
    // viewInsets はキーボードの高さ。0 より大きければ出ている。
    if (MediaQuery.viewInsetsOf(context).bottom > 0) {
      return const SizedBox.shrink();
    }
    final palette = context.palette;

    return MobileAdSlot(
      adUnitId: AdUnitIds.sheetBanner,
      // こちらは大型のまま。シートは開いている間だけのもので、下半分は
      // 元から余っているため常設のバナーほど圧迫しない。
      resolveSize: (context) =>
          AdSize.getLargeAnchoredAdaptiveBannerAdSize(_adWidth(context)),
      builder: (context, adView) => Container(
        padding: const EdgeInsets.fromLTRB(
          _horizontalPadding,
          _topPadding,
          _horizontalPadding,
          _bottomPadding,
        ),
        decoration: BoxDecoration(
          color: palette.surfaceHeader,
          border: Border(top: BorderSide(color: palette.borderAlpha(8))),
        ),
        child: adView,
      ),
    );
  }

  /// 広告に渡す幅。シートは画面幅いっぱい(iPad ではシェルと同じ上限)。
  int _adWidth(BuildContext context) {
    final available = math.min(
      MediaQuery.sizeOf(context).width,
      AppDimensions.mobileContentMaxWidth,
    );
    return (available - _horizontalPadding * 2).truncate();
  }
}
