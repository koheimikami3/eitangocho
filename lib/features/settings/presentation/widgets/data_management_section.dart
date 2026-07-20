import 'dart:convert';

import 'package:eitangocho/components/app_outlined_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/features/settings/data/word_export_service.dart';
import 'package:eitangocho/features/settings/presentation/widgets/import_result_dialog.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _jsonTypeGroup = XTypeGroup(label: 'JSON', extensions: ['json']);

/// ボタン hover 背景(プロトタイプの #f5f5f6)。
const _hoverBackground = Color(0xFFF5F5F6);

/// 設定画面の「データ」セクション。JSON エクスポート/インポートの導線。
class DataManagementSection extends ConsumerStatefulWidget {
  const DataManagementSection({super.key});

  @override
  ConsumerState<DataManagementSection> createState() =>
      _DataManagementSectionState();
}

class _DataManagementSectionState
    extends ConsumerState<DataManagementSection> {
  bool _busy = false;

  Future<void> _export() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final now = DateTime.now();
      final suggestedName =
          'eitangocho-'
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}.json';
      final location = await getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: const [_jsonTypeGroup],
      );
      if (location == null) return;

      final json = await ref.read(wordExportServiceProvider).exportJson();
      final file = XFile.fromData(
        utf8.encode(json),
        mimeType: 'application/json',
        name: suggestedName,
      );
      await file.saveTo(location.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('エクスポートしました')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final file = await openFile(
        acceptedTypeGroups: const [_jsonTypeGroup],
      );
      if (file == null) return;

      final source = await file.readAsString();
      try {
        final result = await ref
            .read(wordExportServiceProvider)
            .importJson(source);
        if (mounted) {
          await showImportResultDialog(context, result);
        }
      } on WordExportFormatException catch (e) {
        if (mounted) {
          await showImportErrorDialog(context, e.message);
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppOutlinedButton(
              label: 'エクスポート...',
              onPressed: _export,
              verticalPadding: 8,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              hoverBackground: _hoverBackground,
            ),
            const SizedBox(width: 10),
            AppOutlinedButton(
              label: 'インポート...',
              onPressed: _import,
              verticalPadding: 8,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              hoverBackground: _hoverBackground,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '単語帳を JSON ファイルとして書き出し / 読み込みます。',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textQuaternary,
          ),
        ),
      ],
    );
  }
}
