import 'dart:convert';

import 'package:eitangocho/features/settings/data/word_export_service.dart';
import 'package:eitangocho/features/settings/presentation/widgets/import_result_dialog.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// JSON バックアップのファイル選択・読み書きと結果表示。
///
/// 変換ロジックそのものは [WordExportService] にあり、ここはその前後の
/// ファイル I/O とダイアログだけを持つ。macOS 版 / iOS 版の設定画面が
/// 見た目だけ変えて同じ処理を呼べるよう、ウィジェットから切り出している。
const _jsonTypeGroup = XTypeGroup(label: 'JSON', extensions: ['json']);

/// 単語帳を JSON ファイルへ書き出す。キャンセル時は何もしない。
Future<void> exportWordsToFile(BuildContext context, WidgetRef ref) async {
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

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('エクスポートしました')),
    );
  }
}

/// JSON ファイルを読み込んでマージする。キャンセル時は何もしない。
Future<void> importWordsFromFile(BuildContext context, WidgetRef ref) async {
  final file = await openFile(acceptedTypeGroups: const [_jsonTypeGroup]);
  if (file == null) return;

  final source = await file.readAsString();
  try {
    final result = await ref
        .read(wordExportServiceProvider)
        .importJson(source);
    if (context.mounted) await showImportResultDialog(context, result);
  } on WordExportFormatException catch (e) {
    if (context.mounted) await showImportErrorDialog(context, e.message);
  }
}
