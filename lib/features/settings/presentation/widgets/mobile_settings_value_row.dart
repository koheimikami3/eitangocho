import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// iOS 版の設定行(ラベル + 右端に値)。バージョン表示などの読み取り専用の行。
class MobileSettingsValueRow extends StatelessWidget {
  const MobileSettingsValueRow({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
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
            value,
            style: TextStyle(fontSize: 13, color: palette.textAlpha(40)),
          ),
        ],
      ),
    );
  }
}
