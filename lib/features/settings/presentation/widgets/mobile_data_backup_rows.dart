import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_divider.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_settings_link_row.dart';
import 'package:eitangocho/features/settings/presentation/word_backup_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版の設定画面「データ」カードのうち、JSON エクスポート/インポートの行。
///
/// 処理そのものは macOS 版と共通([exportWordsToFile] /
/// [importWordsFromFile])で、ここは見た目と多重実行の抑止だけを持つ。
/// 2 行を 1 つのウィジェットにまとめているのは、[_busy] を両方で共有して
/// 書き出し中の読み込み(およびその逆)を止めるため。
class MobileDataBackupRows extends ConsumerStatefulWidget {
  const MobileDataBackupRows({super.key});

  @override
  ConsumerState<MobileDataBackupRows> createState() =>
      _MobileDataBackupRowsState();
}

class _MobileDataBackupRowsState extends ConsumerState<MobileDataBackupRows> {
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
        MobileSettingsLinkRow(
          label: 'データを書き出す',
          onTap: () => _run(exportWordsToFile),
        ),
        const MobileSettingsDivider(),
        MobileSettingsLinkRow(
          label: 'データを読み込む',
          onTap: () => _run(importWordsFromFile),
        ),
      ],
    );
  }
}
