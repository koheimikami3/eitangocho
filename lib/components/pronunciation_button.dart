import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/providers/audio_player_provider.dart';
import 'package:eitangocho/utils/google_translate_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// 発音ボタン(機能横断コンポーネント)。
/// [audioUrl] があれば円形の再生ボタン、無ければ Google 翻訳への
/// 外部リンク(通常は「発音を確認 ↗」、[compactLink] なら「↗」のみ)。
/// 自身がタップを消費するため、カード・行のクリック(編集モーダル)には
/// 伝播しない。
class PronunciationButton extends ConsumerStatefulWidget {
  const PronunciationButton({
    required this.word,
    required this.audioUrl,
    super.key,
    this.size = 28,
    this.compactLink = false,
  });

  final String word;
  final String audioUrl;

  /// 円形ボタンの直径(カード 28 / テーブル 26 / クイズ表面 32・答え面 28)
  final double size;

  /// リンク表示を「↗」のみにする(テーブルの発音列用)
  final bool compactLink;

  @override
  ConsumerState<PronunciationButton> createState() =>
      _PronunciationButtonState();
}

class _PronunciationButtonState extends ConsumerState<PronunciationButton> {
  bool _isHovered = false;

  Future<void> _play() async {
    final player = ref.read(audioPlayerProvider);
    try {
      // 再生中なら止めてから差し替える(1 インスタンス共有のため)
      await player.stop();
      await player.setUrl(widget.audioUrl);
      await player.play();
    } on Exception {
      // URL 切れ等で失敗してもクラッシュさせず軽く通知する
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('発音音声を再生できませんでした')),
        );
      }
    }
  }

  Future<void> _openGoogleTranslate() async {
    await launchUrl(googleTranslateUrl(widget.word));
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: widget.audioUrl.isNotEmpty ? _buildPlayButton() : _buildLink(),
    );
  }

  Widget _buildPlayButton() {
    return Tooltip(
      message: '発音を再生',
      child: GestureDetector(
        onTap: _play,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isHovered
                ? const Color(0xFFECEEF2)
                : AppColors.inputBackground,
            border: Border.all(color: const Color(0x1F000000)),
          ),
          child: Icon(
            Icons.volume_up,
            size: widget.size * 0.55,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }

  Widget _buildLink() {
    return Tooltip(
      message: widget.compactLink ? '外部サイトで発音を確認' : '',
      child: GestureDetector(
        onTap: _openGoogleTranslate,
        child: Text(
          widget.compactLink ? '↗' : '発音を確認 ↗',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.accent,
            decoration:
                _isHovered ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
