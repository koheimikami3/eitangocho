import 'package:eitangocho/components/mobile_pronunciation_button.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/utils/google_translate_url.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// iOS 版のクイズカード(表面 + 答え面)。
///
/// 発音ボタンは答えがバレないよう、英単語が出ている側にだけ置く
/// ([audioOnFront] が表面 = 英単語かどうか)。
class MobileQuizCard extends StatelessWidget {
  const MobileQuizCard({
    required this.front,
    required this.ipa,
    required this.revealed,
    required this.back,
    required this.exampleEn,
    required this.exampleJa,
    required this.englishWord,
    required this.audioUrl,
    required this.audioOnFront,
    super.key,
  });

  final String front;
  final String ipa;
  final bool revealed;
  final String back;
  final String exampleEn;
  final String exampleJa;

  /// 発音の対象(表裏に関わらず常に英単語)
  final String englishWord;
  final String audioUrl;

  /// 表面が英単語側か(false なら答え面に発音ボタンを置く)
  final bool audioOnFront;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final showAudioOnFront = audioOnFront;
    final showAudioOnBack = !audioOnFront && revealed;

    return Container(
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.borderAlpha(10)),
        boxShadow: [
          BoxShadow(
            color: palette.borderAlpha(6),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  front,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: palette.text,
                  ),
                ),
              ),
              if (showAudioOnFront && audioUrl.isNotEmpty) ...[
                const SizedBox(width: 12),
                MobilePronunciationButton(
                  word: englishWord,
                  audioUrl: audioUrl,
                  size: 36,
                ),
              ],
            ],
          ),
          // 音声が無い英単語側では外部リンクにフォールバックする。
          if (showAudioOnFront && audioUrl.isEmpty) ...[
            const SizedBox(height: 8),
            _TranslateLink(word: englishWord),
          ],
          if (ipa.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              ipa,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Menlo',
                color: palette.textAlpha(45),
              ),
            ),
          ],
          if (revealed) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 14),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: palette.borderAlpha(8)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      back,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, color: palette.text),
                    ),
                  ),
                  if (showAudioOnBack && audioUrl.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    MobilePronunciationButton(
                      word: englishWord,
                      audioUrl: audioUrl,
                    ),
                  ],
                ],
              ),
            ),
            if (showAudioOnBack && audioUrl.isEmpty) ...[
              const SizedBox(height: 8),
              _TranslateLink(word: englishWord),
            ],
            if (exampleEn.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                exampleJa.trim().isEmpty
                    ? exampleEn
                    : '$exampleEn\n$exampleJa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: palette.textAlpha(55),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _TranslateLink extends StatelessWidget {
  const _TranslateLink({required this.word});

  final String word;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(googleTranslateUrl(word)),
      child: Text(
        '発音を確認 ↗',
        style: TextStyle(fontSize: 12, color: context.palette.accent),
      ),
    );
  }
}
