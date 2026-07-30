import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/providers/audio_player_provider.dart';
import 'package:eitangocho/utils/google_translate_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// iOS 版の発音ボタン。
///
/// macOS 版の [PronunciationButton] と役割は同じだが、ホバー演出と Tooltip を
/// 持たず(タッチでは出ないため)、配色を [AppPalette] から引く。
/// audioUrl があれば円形の再生ボタン、無ければ Google 翻訳への外部リンク。
class MobilePronunciationButton extends ConsumerWidget {
  const MobilePronunciationButton({
    required this.word,
    required this.audioUrl,
    super.key,
    this.size = 32,
  });

  final String word;
  final String audioUrl;

  /// 円形ボタンの直径(カード・行 32 / クイズ表面 36)
  final double size;

  Future<void> _play(BuildContext context, WidgetRef ref) async {
    final player = ref.read(audioPlayerProvider);
    try {
      // 再生中なら止めてから差し替える(1 インスタンス共有のため)
      await player.stop();
      await player.setUrl(audioUrl);
      await player.play();
    } on Exception {
      // URL 切れ等で失敗してもクラッシュさせず軽く通知する
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('発音音声を再生できませんでした')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;

    if (audioUrl.isEmpty) {
      return GestureDetector(
        onTap: () => launchUrl(googleTranslateUrl(word)),
        // 「↗」だけだとタップ領域が小さすぎるため padding で広げる。
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Text(
            '↗',
            style: TextStyle(fontSize: 13, color: palette.accent),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _play(context, ref),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: palette.surfaceAlt,
          border: Border.all(color: palette.borderAlpha(12)),
        ),
        child: Icon(
          Icons.volume_up,
          size: size * 0.47,
          color: palette.accent,
        ),
      ),
    );
  }
}
