import 'package:eitangocho/features/settings/presentation/widgets/settings_divider.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_link_row.dart';
import 'package:eitangocho/features/settings/presentation/word_backup_actions.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// macOS 版の設定画面「データ」カードのうち、JSON エクスポート/インポートの行。
///
/// ラベル末尾の `...` は macOS だけに付ける(ダイアログが開くことを示す
/// macOS の慣習。デザインからは消えたがユーザー判断で維持している)。
/// 2 行を 1 つのウィジェットにまとめているのは、[_busy] を両方で共有して
/// 書き出し中の読み込み(およびその逆)を止めるため。
class DataBackupRows extends ConsumerStatefulWidget {
  const DataBackupRows({super.key});

  @override
  ConsumerState<DataBackupRows> createState() => _DataBackupRowsState();
}

class _DataBackupRowsState extends ConsumerState<DataBackupRows> {
  bool _busy = false;

  Future<void> _run(
    Future<void> Function(BuildContext, WidgetRef) action,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action(context, ref);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsLinkRow(
          label: context.l10n.exportDataEllipsis,
          onTap: () => _run(exportWordsToFile),
        ),
        const SettingsDivider(),
        SettingsLinkRow(
          label: context.l10n.importDataEllipsis,
          onTap: () => _run(importWordsFromFile),
        ),
      ],
    );
  }
}
