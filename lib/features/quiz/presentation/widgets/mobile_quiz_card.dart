import 'package:eitangocho/components/mobile_pronunciation_button.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// iOS 版のクイズカード(表面 + 答え面)。
///
/// 発音リンクは答えがバレないよう、英単語が出ている側にだけ置く
/// ([pronunciationOnFront] が表面 = 英単語かどうか)。
class MobileQuizCard extends StatelessWidget {
  const MobileQuizCard({
    required this.front,
    required this.ipa,
    required this.revealed,
    required this.back,
    required this.exampleEn,
    required this.exampleJa,
    required this.englishWord,
    required this.pronunciationOnFront,
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

  /// 表面が英単語側か(false なら答え面に発音リンクを置く)
  final bool pronunciationOnFront;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final showLinkOnBack = !pronunciationOnFront && revealed;

    return Container(
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.cardBorder),
        boxShadow: palette.sheetShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            front,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: palette.text,
            ),
          ),
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
          // 発音リンクは IPA の下に置く(macOS 版の QuizCard と揃える)。
          if (pronunciationOnFront) ...[
            const SizedBox(height: 8),
            MobilePronunciationButton(
              word: englishWord,
              variant: MobilePronunciationButtonVariant.pill,
            ),
          ],
          if (revealed) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: palette.rowLine)),
              ),
              child: Text(
                back,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, color: palette.text),
              ),
            ),
            if (showLinkOnBack) ...[
              const SizedBox(height: 8),
              MobilePronunciationButton(
                word: englishWord,
                variant: MobilePronunciationButtonVariant.pill,
              ),
            ],
            if (exampleEn.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                exampleJa.trim().isEmpty ? exampleEn : '$exampleEn\n$exampleJa',
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
