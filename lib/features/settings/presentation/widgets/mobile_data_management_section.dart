import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/presentation/word_backup_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版の設定画面「データ」セクション。JSON エクスポート/インポートの導線。
///
/// 処理そのものは macOS 版と共通([exportWordsToFile] /
/// [importWordsFromFile])で、ここは見た目と多重実行の抑止だけを持つ。
class MobileDataManagementSection extends ConsumerStatefulWidget {
  const MobileDataManagementSection({super.key});

  @override
  ConsumerState<MobileDataManagementSection> createState() =>
      _MobileDataManagementSectionState();
}

class _MobileDataManagementSectionState
    extends ConsumerState<MobileDataManagementSection> {
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
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _DataButton(
                label: 'エクスポート',
                onTap: () => _run(exportWordsToFile),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DataButton(
                label: 'インポート',
                onTap: () => _run(importWordsFromFile),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '単語帳を JSON ファイルとして書き出し / 読み込みます。',
          style: TextStyle(fontSize: 11, color: palette.textAlpha(40)),
        ),
      ],
    );
  }
}

class _DataButton extends StatelessWidget {
  const _DataButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: palette.borderAlpha(14)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: palette.text),
        ),
      ),
    );
  }
}
