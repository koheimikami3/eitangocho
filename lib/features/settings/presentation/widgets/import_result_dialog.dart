import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/features/settings/data/word_export_service.dart';
import 'package:flutter/material.dart';

/// インポート結果(追加/更新/変更なし/スキップ件数)を表示するダイアログ。
/// 意匠は delete_confirm_dialog.dart に準拠(角丸 13 / width 380)。
Future<void> showImportResultDialog(BuildContext context, ImportResult result) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'インポートが完了しました',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text('追加 ${result.added} 件'),
              Text('更新 ${result.updated} 件'),
              Text('変更なし ${result.unchanged} 件'),
              Text('スキップ ${result.skipped} 件'),
              const SizedBox(height: 16),
              AppFilledButton(
                label: '閉じる',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// インポートに失敗したときのエラーダイアログ。
Future<void> showImportErrorDialog(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'インポートできませんでした',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              AppFilledButton(
                label: '閉じる',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
