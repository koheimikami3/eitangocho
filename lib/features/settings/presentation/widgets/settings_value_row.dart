import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 設定カード内の読み取り専用行(ラベル + 右端に値)。バージョン表示など。
class SettingsValueRow extends StatelessWidget {
  const SettingsValueRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: colors.textPrimary),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 13, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}
