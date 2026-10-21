import 'package:eitangocho/components/mobile_pressable.dart';
import 'package:eitangocho/components/mobile_pronunciation_button.dart';
import 'package:eitangocho/constants/app_fonts.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_learned_checkbox.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_pos_badge.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';

/// iOS 版の全単語リストの 1 行。
///
/// macOS 版は 8 列のテーブル([WordTableRow])だが、iPhone 幅では成立しないため
/// チェック / 単語 + IPA + 品詞・訳 / 発音 の 1 行にまとめる。
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
                  // 品詞は IPA の後ろに続けて置き、訳の行は幅いっぱいを使わせる。
                  // 訳の横に並べると品詞が多い単語ほど訳がすぐ省略されるため。
                  // 単語・IPA と並ばないときは品詞だけ次の行に回す(その行は
                  // 3 段になる)。単語・IPA を削って品詞を同じ行に収めはしない。
                  // 右寄せにしないのは、次の行に回ったときに右端から左端へ
                  // 位置が飛んで、その行だけ浮いて見えるため。
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 3,
                    children: [
                      _WordAndIpa(
                        word: word.word,
                        ipa: showIpaText ? word.ipa : null,
                      ),
                      MobilePosBadge(partsOfSpeech: word.partsOfSpeech),
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
                      context.l10n.correctCount(word.correctCount),
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

/// 単語と IPA を 1 行に並べる。
///
/// 行の幅に収まらないときは、単語は省略せず(長ければ折り返す)、
/// 補助情報の IPA を末尾から省略する。Row の Flexible 同士では幅が flex の比で
/// 山分けになり、短い単語でも IPA が半分の幅で切られるため、単語の幅を先に
/// 確定させて残りを IPA に渡す。
/// 横幅は中身の分だけ取る(品詞を同じ行に並べられるかの判定に使うため)。
class _WordAndIpa extends StatelessWidget {
  const _WordAndIpa({required this.word, required this.ipa});

  final String word;

  /// null なら IPA を出さない。
  final String? ipa;

  /// 単語と IPA の間隔。
  static const _gap = 7.0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ipa = this.ipa;

    return LayoutBuilder(
      builder: (context, constraints) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ipa == null
                  ? constraints.maxWidth
                  : constraints.maxWidth - _gap,
            ),
            child: Text(
              word,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: palette.text,
              ),
            ),
          ),
          if (ipa != null) ...[
            const SizedBox(width: _gap),
            Flexible(
              child: Text(
                ipa,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: AppFonts.ipa,
                  color: palette.textAlpha(45),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
