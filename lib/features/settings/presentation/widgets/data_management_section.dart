import 'package:eitangocho/components/app_outlined_button.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_caption.dart';
import 'package:eitangocho/features/settings/presentation/word_backup_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ボタン hover 背景(プロトタイプの #f5f5f6)。
const _hoverBackground = Color(0xFFF5F5F6);

/// macOS 版の設定画面「データ」セクションのうち、JSON エクスポート/インポートの導線。
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
      await exportWordsToFile(context, ref);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await importWordsFromFile(context, ref);
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
        const SettingsCaption('単語帳を JSON ファイルとして書き出し / 読み込みます。'),
      ],
    );
  }
}
