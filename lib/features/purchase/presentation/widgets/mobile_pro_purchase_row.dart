import 'dart:math' as math;

import 'package:eitangocho/components/mobile_pressable.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/purchase/data/purchase_notifier.dart';
import 'package:eitangocho/l10n/app_localizations.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 設定画面「Pro」の購入行(説明 + 価格 + 購入ボタン)。
///
/// 「開発者へのコーヒーの差し入れ」を主役にし、広告の非表示はそのお礼として
/// 見せる。商品(広告の非表示)と寄付(差し入れ)を同じ重さで並べると、
/// 何を買うのかがぼやけるため。
class MobileProPurchaseRow extends ConsumerWidget {
  const MobileProPurchaseRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final state = ref.watch(purchaseProvider);
    final done = state.proUnlocked;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.proCoffeeTitle,
                  style: TextStyle(fontSize: 14, color: palette.text),
                ),
                const SizedBox(height: 3),
                // 購入済みならお礼の 1 行だけ。価格もお礼の内容(広告の非表示)も
                // もう要らない。
                if (done)
                  Text(
                    context.l10n.proCoffeeThanks,
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.textAlpha(45),
                    ),
                  )
                else ...[
                  // お礼(広告の非表示)は薄字にしない。薄いと「差し入れるだけ」に
                  // 見え、何が得られるのかが伝わらないため。
                  Text(
                    context.l10n.proCoffeeReward,
                    style: TextStyle(fontSize: 12, color: palette.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _note(
                      context.l10n,
                      failed: state.purchaseFailed,
                      priceText: state.priceText,
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: state.purchaseFailed
                          ? palette.danger
                          : palette.textAlpha(45),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 見出しを 1 行に収めるため、ボタンとの間隔とボタンの左右の余白は
          // 他の行より詰めている(ボタンの幅は「購入済み」に合わせて固定のため)。
          const SizedBox(width: 8),
          _PurchaseButton(
            done: done,
            purchasing: state.purchasing,
            // 価格が引けていない = 商品を取得できていないので押させない。
            onTap: state.priceText == null
                ? null
                : ref.read(purchaseProvider.notifier).buy,
          ),
        ],
      ),
    );
  }

  /// 未購入のときの価格の行。失敗メッセージは一時的に価格を置き換える
  /// (お礼の行はそのまま残す)。
  String _note(
    AppLocalizations l10n, {
    required bool failed,
    required String? priceText,
  }) {
    if (failed) return l10n.purchaseFailed;
    if (priceText == null) return l10n.priceUnavailable;
    return l10n.oneTimePrice(priceText);
  }
}

class _PurchaseButton extends StatelessWidget {
  const _PurchaseButton({
    required this.done,
    required this.purchasing,
    required this.onTap,
  });

  final bool done;
  final bool purchasing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // 購入済み・処理中・商品を引けていないときは押せない。
    final enabled = !done && !purchasing && onTap != null;
    // 押せる間と処理中は青いまま。押せなくなったらグレーに落とす
    // (購入済みだけでなく、価格を引けなかったときもこちら)。
    final filled = enabled || purchasing;
    const textStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);

    return MobilePressable(
      onTap: enabled ? onTap : null,
      builder: (context, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? null : palette.proButtonDone,
          gradient: filled ? palette.buttonGradient : null,
          borderRadius: BorderRadius.circular(9),
          boxShadow: filled ? palette.buttonShadow : null,
        ),
        // 大きさは「購入」「購入済み」・インジケータのうち最も大きいものに
        // 固定し、表示の切り替え(購入 → インジケータ → 購入済み)でボタンが
        // 伸び縮みしないようにする。
        child: SizedBox.fromSize(
          size: _contentSize(context, textStyle),
          child: Center(
            child: purchasing
                // App Store のダイアログが出るまでの待ちを埋める。
                ? const SizedBox(
                    width: _indicatorSize,
                    height: _indicatorSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    done ? context.l10n.purchased : context.l10n.purchase,
                    style: textStyle.copyWith(
                      color: filled
                          ? Colors.white
                          : palette.proButtonDoneForeground,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// 処理中のインジケータの直径。
  static const _indicatorSize = 16.0;

  /// ボタンの中身の大きさ。「購入」「購入済み」の大きい方で、インジケータより
  /// 小さくはしない。どちらの文字が大きいかは言語や書体で変わるため、
  /// 決め打ちにせず実際の文字で測る。見えない文字を重ねて大きさを取る手も
  /// あるが、読み上げやテストで同じ文言が二重に見つかるので測る方を取る。
  Size _contentSize(BuildContext context, TextStyle style) {
    // Text と同じ書体で測るため、既定の文字スタイルに重ねる。
    final resolved = DefaultTextStyle.of(context).style.merge(style);
    Size sizeOf(String text) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: resolved),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final size = painter.size;
      painter.dispose();
      return size;
    }

    final purchase = sizeOf(context.l10n.purchase);
    final purchased = sizeOf(context.l10n.purchased);
    return Size(
      math.max(purchase.width, purchased.width).ceilToDouble(),
      math
          .max(_indicatorSize, math.max(purchase.height, purchased.height))
          .ceilToDouble(),
    );
  }
}
