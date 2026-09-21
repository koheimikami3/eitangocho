import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// 辞書から自動入力された項目を示す小さなバッジ。
class MobileAutoFillBadge extends StatelessWidget {
  const MobileAutoFillBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: palette.autoFillBadgeBackground,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '自動入力',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: palette.autoFillBadgeForeground,
        ),
      ),
    );
  }
}
