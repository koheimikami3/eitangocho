import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/ads/domain/ad_unit_ids.dart';
import 'package:eitangocho/features/ads/presentation/widgets/mobile_ad_slot.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// クイズ結果に出す 300x250 レクタングル(iOS のみ)。
///
/// 忘れていた単語の一覧とボタンの間に置く(デザインどおり)。ここだけ
/// アダプティブではなく固定サイズなのは、レクタングルは寸法が決まった
/// フォーマットで、幅に合わせて伸縮しないため。
///
/// デザインの枠は白地・1px 枠線・角丸 12 で、幅いっぱいに広がっている。
/// 実際の広告は 300pt 固定なので、枠を広告幅に合わせて中央に置く
/// (幅いっぱいの枠にすると左右に白帯が残る)。
class MobileQuizRectangleAd extends StatelessWidget {
  const MobileQuizRectangleAd({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return MobileAdSlot(
      adUnitId: AdUnitIds.quizRectangle,
      resolveSize: (context) async => AdSize.mediumRectangle,
      // 上の余白はここで持つ。広告が無いときに空白だけが残らないよう、
      // 呼び出し側(クイズ結果)には隙間を持たせない。
      builder: (context, adView) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.borderAlpha(10)),
            ),
            clipBehavior: Clip.antiAlias,
            child: adView,
          ),
        ),
      ),
    );
  }
}
