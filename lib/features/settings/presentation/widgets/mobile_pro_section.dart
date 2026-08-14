import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// 設定の「Pro」セクション(広告非表示の買い切り)。**iOS 専用**。
///
/// **今は見た目だけで、購入も復元も何もしない。** 課金の実装(StoreKit)は
/// 別途で、入ったときに [adsEnabledProvider] へ購入状態を混ぜる想定。
/// デザインどおりの枠を先に置いているだけなので、押しても状態は変わらない。
class MobileProSection extends StatelessWidget {
  const MobileProSection({super.key});

  /// 買い切りの価格。**デザインの仮値**で、課金の実装時に
  /// App Store から取得した実価格に差し替える(地域で変わるため直書きできない)。
  static const _price = '買い切り ¥600';

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.borderAlpha(10)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '広告を非表示にする',
                        style: TextStyle(fontSize: 14, color: palette.text),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _price,
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.textAlpha(45),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const _PurchaseButton(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Divider(
              height: 1,
              thickness: 1,
              color: palette.borderAlpha(7),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Text(
              '購入を復元',
              style: TextStyle(fontSize: 13, color: palette.accentOnSoft),
            ),
          ),
        ],
      ),
    );
  }
}

/// 「購入」ボタン。押しても何も起きない(上のクラスのコメント参照)。
class _PurchaseButton extends StatelessWidget {
  const _PurchaseButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        // ライト / ダークとも同じ濃い青にする。地の明るさに関わらず白文字の
        // コントラストを 4.5:1 以上に保つため(デザインの #1E7FD6 は 4.23:1 で
        // 足りない。発音ボタンと同じ振り直し。AppColors.accentOnSoft 参照)。
        color: AppColors.accentOnSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '購入',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
