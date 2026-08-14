import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 設定画面のセクション(見出し + 中身)。プロトタイプの見出し意匠に合わせる。
class SettingsSection extends StatelessWidget {
  const SettingsSection({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
