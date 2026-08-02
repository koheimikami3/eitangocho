import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/utils/google_translate_url.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 発音確認リンク(機能横断コンポーネント)。Google 翻訳を外部ブラウザで開く。
/// 通常は「発音を確認 ↗」、[compact] なら「↗」のみ(テーブルの発音列用)。
/// 自身がタップを消費するため、カード・行のクリック(編集モーダル)には
/// 伝播しない。
class PronunciationLink extends StatefulWidget {
  const PronunciationLink({
    required this.word,
    super.key,
    this.compact = false,
  });

  final String word;

  /// 表示を「↗」のみにする(テーブルの発音列用)
  final bool compact;

  @override
  State<PronunciationLink> createState() => _PronunciationLinkState();
}

class _PronunciationLinkState extends State<PronunciationLink> {
  bool _isHovered = false;

  Future<void> _openGoogleTranslate() async {
    await launchUrl(googleTranslateUrl(widget.word));
  }

  @override
  Widget build(BuildContext context) {
    final link = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _openGoogleTranslate,
        child: Text(
          widget.compact ? '↗' : '発音を確認 ↗',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.accent,
            decoration:
                _isHovered ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );

    // 「↗」だけでは用途が分からないため、compact のときだけ説明を出す。
    return widget.compact
        ? Tooltip(message: '外部サイトで発音を確認', child: link)
        : link;
  }
}
