import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/purchase/data/purchase_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 設定画面「Pro」の購入行(説明 + 価格 + 購入ボタン)。
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
                  '広告を非表示にする',
                  style: TextStyle(fontSize: 14, color: palette.text),
                ),
                const SizedBox(height: 3),
                Text(
                  _note(state.purchaseMessage, state.priceText, done: done),
                  style: TextStyle(
                    fontSize: 11,
                    color: state.purchaseMessage != null
                        ? palette.danger
                        : palette.textAlpha(45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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

  /// ボタンの下の補足。失敗メッセージは一時的に価格を置き換える。
  String _note(String? message, String? priceText, {required bool done}) {
    if (message != null) return message;
    if (done) return 'Pro を購入済みです';
    if (priceText == null) return '価格を取得できませんでした';
    return '買い切り $priceText';
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? palette.proButton : palette.proButtonDone,
          borderRadius: BorderRadius.circular(8),
        ),
        child: purchasing
            // App Store のダイアログが出るまでの待ちを埋める。文字と同じ高さに
            // 収めて、ボタンの大きさが変わらないようにする。
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                done ? '購入済み' : '購入',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: filled
                      ? Colors.white
                      : palette.proButtonDoneForeground,
                ),
              ),
      ),
    );
  }
}
