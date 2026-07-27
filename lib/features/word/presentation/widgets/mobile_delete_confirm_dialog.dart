import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版の削除確認ダイアログ(iOS 標準アラート風の 2 分割ボタン)。
/// 確定すると true を返す(呼び出し側は編集シートを閉じる判断に使う)。
Future<bool> showMobileDeleteConfirmDialog(
  BuildContext context,
  WidgetRef ref,
  Word word,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0x66141923), // rgba(20,25,35,0.4)
    builder: (context) => _MobileDeleteConfirmDialog(word: word),
  );

  if (confirmed ?? false) {
    await ref.read(databaseProvider).wordDao.deleteWord(word.id);
    return true;
  }
  return false;
}

class _MobileDeleteConfirmDialog extends StatelessWidget {
  const _MobileDeleteConfirmDialog({required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Dialog(
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
                  Text(
                    '「${word.word}」を削除しますか?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: palette.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'この操作は取り消せません。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.textAlpha(50),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: palette.borderAlpha(10)),
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _AlertAction(
                        label: 'やめる',
                        color: palette.accent,
                        onTap: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: palette.borderAlpha(10),
                    ),
                    Expanded(
                      child: _AlertAction(
                        label: '削除する',
                        color: palette.danger,
                        bold: true,
                        onTap: () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertAction extends StatelessWidget {
  const _AlertAction({
    required this.label,
    required this.color,
    required this.onTap,
    this.bold = false,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}
