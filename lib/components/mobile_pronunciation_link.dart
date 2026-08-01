import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/utils/google_translate_url.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// iOS 版の発音確認リンク。
///
/// macOS 版の [PronunciationLink] と役割は同じだが、ホバー演出と Tooltip を
/// 持たず(タッチでは出ないため)、配色を [AppPalette] から引く。
class MobilePronunciationLink extends StatelessWidget {
  const MobilePronunciationLink({
    required this.word,
    super.key,
    this.compact = false,
  });

  final String word;

  /// 表示を「↗」のみにする(カード・一覧行用)
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      compact ? '↗' : '発音を確認 ↗',
      style: TextStyle(
        fontSize: compact ? 13 : 12,
        color: context.palette.accent,
      ),
    );

    return GestureDetector(
      onTap: () => launchUrl(googleTranslateUrl(word)),
      child: compact
          // 「↗」だけだとタップ領域が小さすぎるため padding で広げる。
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: label,
            )
          : label,
    );
  }
}
