import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// iOS 版の設定行(ラベル + 右端のシェブロン)。タップで別画面に遷移する行。
class MobileSettingsLinkRow extends StatelessWidget {
  const MobileSettingsLinkRow({
    required this.label,
    required this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: palette.text),
              ),
            ),
            Text(
              '›',
              style: TextStyle(
                fontSize: 16,
                height: 1,
                color: palette.textAlpha(30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
