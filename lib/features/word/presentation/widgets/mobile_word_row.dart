import 'package:eitangocho/components/mobile_pressable.dart';
import 'package:eitangocho/components/mobile_pronunciation_button.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_learned_checkbox.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_pos_badge.dart';
import 'package:flutter/material.dart';

/// iOS 版の全単語リストの 1 行。
///
/// macOS 版は 8 列のテーブル([WordTableRow])だが、iPhone 幅では成立しないため
/// チェック / 単語 + IPA + 訳 / 品詞 / 発音 の 1 行にまとめる。
class MobileWordRow extends StatelessWidget {
  const MobileWordRow({
    required this.word,
    required this.showIpa,
    required this.onToggleLearned,
    required this.onTap,
    this.showCorrectCount = false,
    super.key,
  });

  final Word word;
  final bool showIpa;
  final ValueChanged<bool> onToggleLearned;
  final VoidCallback onTap;

  /// 覚えた回数(correctCount)を訳の下の行に出すか。
  /// 普段は出さず、覚えた回数で並べているときだけ並びの根拠として見せる。
  final bool showCorrectCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final showIpaText = showIpa && word.ipa.isNotEmpty;

    return MobilePressable(
      onTap: onTap,
      style: MobilePressStyle.row,
      builder: (context, pressed) => Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: pressed
              ? palette.pressBackground
              : word.isLearned
              ? palette.surfaceHeader
              : palette.surface,
          border: Border(bottom: BorderSide(color: palette.rowLine)),
        ),
        child: Row(
          children: [
            // チェック操作を行のタップ(編集)に伝播させない。
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onToggleLearned(!word.isLearned),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: MobileLearnedCheckbox(value: word.isLearned),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 7,
                    children: [
                      Text(
                        word.word,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: palette.text,
                        ),
                      ),
                      if (showIpaText)
                        Text(
                          word.ipa,
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'Menlo',
                            color: palette.textAlpha(45),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    word.meaning,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: palette.textAlpha(60),
                    ),
                  ),
                  // 単語の横に並べると、単語の長さ次第で折り返したり
                  // しなかったりして行ごとに位置が揃わないため、常に独立した行にする。
                  if (showCorrectCount) ...[
                    const SizedBox(height: 3),
                    Text(
                      '覚えた ${word.correctCount}回',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: palette.accentOnSoft,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            MobilePosBadge(partsOfSpeech: word.partsOfSpeech),
            const SizedBox(width: 8),
            MobilePronunciationButton(
              word: word.word,
              variant: MobilePronunciationButtonVariant.icon,
            ),
          ],
        ),
      ),
    );
  }
}
