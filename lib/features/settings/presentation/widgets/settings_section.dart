import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:flutter/material.dart';

/// 設定画面のセクション(見出し + 中身)。プロトタイプの見出し意匠に合わせる。
class SettingsSection extends StatelessWidget {
  const SettingsSection({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 見出しはカードの外枠ではなく、角丸が終わる位置まで内側に寄せる
        // (iOS の MobileSettingsSection と同じ)。
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.mobileCardRadius,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
