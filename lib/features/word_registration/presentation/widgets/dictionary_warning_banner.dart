import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 辞書未収録などの警告バナー(フォーム上部に表示。プロトタイプ準拠)。
class DictionaryWarningBanner extends StatelessWidget {
  const DictionaryWarningBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warningBannerBackground,
        border: Border.all(color: AppColors.warningBannerBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.warningBannerForeground,
        ),
      ),
    );
  }
}
