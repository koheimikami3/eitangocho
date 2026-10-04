import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/features/settings/data/word_export_service.dart';
import 'package:eitangocho/utils/l10n_context.dart';
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
              Text(
                context.l10n.importDoneTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(context.l10n.importAdded(result.added)),
              Text(context.l10n.importUpdated(result.updated)),
              Text(context.l10n.importUnchanged(result.unchanged)),
              Text(context.l10n.importSkipped(result.skipped)),
              const SizedBox(height: 16),
              AppFilledButton(
                label: context.l10n.close,
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
Future<void> showImportErrorDialog(
  BuildContext context,
  WordExportFormatError error,
) {
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
              Text(
                context.l10n.importFailedTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(switch (error) {
                WordExportFormatError.invalidJson =>
                  context.l10n.importErrorInvalidJson,
                WordExportFormatError.invalidFormat =>
                  context.l10n.importErrorInvalidFormat,
                WordExportFormatError.unsupportedVersion =>
                  context.l10n.importErrorUnsupportedVersion,
              }, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              AppFilledButton(
                label: context.l10n.close,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
