import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 辞書未収録などの警告バナー(フォーム上部に表示。プロトタイプ準拠)。
class DictionaryWarningBanner extends StatelessWidget {
  const DictionaryWarningBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.warningBannerBackground,
        border: Border.all(color: colors.warningBannerBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 13, color: colors.warningBannerForeground),
      ),
    );
  }
}
