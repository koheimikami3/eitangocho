import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 自動取得できた項目のラベル横に出すピルバッジ(プロトタイプ準拠)。
class AutoFillBadge extends StatelessWidget {
  const AutoFillBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.autoFillBadgeBackground,
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Text(
        '自動入力',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.autoFillBadgeForeground,
        ),
      ),
    );
  }
}
