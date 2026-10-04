import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/purchase/data/purchase_notifier.dart';
import 'package:eitangocho/features/purchase/domain/purchase_state.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 設定画面「Pro」の復元行。
///
/// 機種変更・再インストールで購入が消えた人のための導線なので、購入済みに
/// 見えているかどうかに関わらず押せる(購入済みのときだけ隠すと、まさに
/// 必要な人が使えない)。
class MobileProRestoreRow extends ConsumerWidget {
  const MobileProRestoreRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final state = ref.watch(purchaseProvider);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: state.restoring
          ? null
          : ref.read(purchaseProvider.notifier).restore,
      child: Padding(
        // 上下 13 は他のリンク行(MobileSettingsLinkRow)と同じ。設定画面の
        // デザイン刷新でカード内の行の高さが揃えられたため、それに合わせる。
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.restorePurchases,
                style: TextStyle(
                  fontSize: 13,
                  // デザインはここに --accText を当てている。その対応色が
                  // accentOnSoft で、13px の文字でも 4.5:1 を満たす
                  // (accent のままだとカード地に対して足りない)。
                  color: state.restoring
                      ? palette.textAlpha(40)
                      : palette.accentOnSoft,
                ),
              ),
            ),
            if (state.restoreStatus case final status?)
              Text(switch (status) {
                RestoreStatus.checking => context.l10n.restoreChecking,
                RestoreStatus.restored => context.l10n.restoreDone,
                RestoreStatus.notFound => context.l10n.restoreNotFound,
                RestoreStatus.failed => context.l10n.restoreFailed,
              }, style: TextStyle(fontSize: 11, color: palette.textAlpha(45))),
          ],
        ),
      ),
    );
  }
}
