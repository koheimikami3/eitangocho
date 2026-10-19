import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/ads/domain/ad_unit_ids.dart';
import 'package:eitangocho/features/ads/presentation/widgets/mobile_ad_slot.dart';
import 'package:eitangocho/features/purchase/presentation/widgets/mobile_pro_link.dart';
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
///
/// 広告の下には Pro への導線([MobileProLink])を添える。builder の中に置くので、
/// 広告が出ていないとき・Pro を購入済みのときは導線も出ない。
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.mobileCardRadius,
                  ),
                  boxShadow: palette.elevation,
                ),
                clipBehavior: Clip.antiAlias,
                child: adView,
              ),
            ),
            // 導線は広告の枠の外に、間隔を空けて置く。広告の一部に見えたり、
            // 広告を誤タップさせたりすると AdMob のポリシー違反(無効なクリック)
            // になりうるため。
            const SizedBox(height: 6),
            const MobileProLink(),
          ],
        ),
      ),
    );
  }
}
