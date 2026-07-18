import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 辞書データ取得中の表示(スピナー + メッセージ)。
class RegistrationLoadingStep extends StatelessWidget {
  const RegistrationLoadingStep({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.accent,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '辞書データを取得中...',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
