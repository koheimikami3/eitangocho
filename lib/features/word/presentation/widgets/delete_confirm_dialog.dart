import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/components/app_outlined_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 削除確認ダイアログ。確定すると true を返す(呼び出し側は編集モーダル等を
/// 閉じるかどうかの判断に使う)。
Future<bool> showDeleteConfirmDialog(
  BuildContext context,
  WidgetRef ref,
  Word word,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.deleteConfirmTitle(word.word),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.deleteConfirmBody,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppOutlinedButton(
                      label: context.l10n.deleteConfirmCancel,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppFilledButton(
                      label: context.l10n.deleteConfirmOk,
                      color: AppColors.danger,
                      hoverColor: AppColors.dangerHover,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  if (confirmed ?? false) {
    await ref.read(databaseProvider).wordDao.deleteWord(word.id);
    return true;
  }
  return false;
}
