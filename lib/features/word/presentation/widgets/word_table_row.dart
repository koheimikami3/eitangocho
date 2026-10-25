import 'package:eitangocho/components/pronunciation_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_fonts.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/presentation/widgets/learned_checkbox.dart';
import 'package:eitangocho/features/word/presentation/widgets/pos_badge.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';

/// 全単語テーブルの 1 行。
class WordTableRow extends StatefulWidget {
  const WordTableRow({
    required this.word,
    required this.onToggleLearned,
    required this.onTap,
    required this.onContextMenu,
    this.showCorrectCount = false,
    super.key,
  });

  final Word word;
  final ValueChanged<bool> onToggleLearned;
  final VoidCallback onTap;

  /// コンテキストメニューを開く。引数はメニューを出すグローバル座標。
  final ValueChanged<Offset> onContextMenu;

  /// 覚えた回数(correctCount)を単語の下に出すか。
  /// 普段は出さず、覚えた回数で並べているときだけ並びの根拠として見せる。
  final bool showCorrectCount;

  @override
  State<WordTableRow> createState() => _WordTableRowState();
}

class _WordTableRowState extends State<WordTableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final word = widget.word;
    final hasExample = word.exampleEn.trim().isNotEmpty;
    final background = _isHovered
        ? colors.rowHoverBackground
        : (word.isLearned ? colors.learnedRowBackground : colors.surface);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTapUp: (details) =>
            widget.onContextMenu(details.globalPosition),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            border: Border(bottom: BorderSide(color: colors.borderAlpha(6))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64,
                // LearnedCheckbox はヒット領域の余白(6)を四辺に持つため、
                // その分だけ左上へ出す。箱の左端が見出し(学習済み)の左端に、
                // 箱の上下中央が 1 行目の単語(13px)の中ほどに揃う。
                child: Transform.translate(
                  offset: const Offset(-6, -6),
                  child: GestureDetector(
                    onTap: () {},
                    child: LearnedCheckbox(
                      value: word.isLearned,
                      onChanged: widget.onToggleLearned,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.word,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    // 単語列は幅が狭いため、iOS と違い横ではなく下に置く。
                    if (widget.showCorrectCount) ...[
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.correctCount(word.correctCount),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.accentOnSoft,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 130,
                child: Text(
                  word.ipa,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: AppFonts.ipa,
                    color: colors.textAlpha(50),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                // ピルはテキスト幅に収める(列幅は整列のため確保)。
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PosBadge(partsOfSpeech: word.partsOfSpeech),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  word.meaning,
                  style: TextStyle(fontSize: 13, color: colors.textAlpha(75)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: hasExample
                    ? Text(
                        '${word.exampleEn}\n${word.exampleTranslation}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                          height: 1.5,
                        ),
                      )
                    : Text(
                        context.l10n.noExample,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textDisabled,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 56,
                child: Align(
                  alignment: Alignment.topLeft,
                  // 行は上揃え(デザインの align-items:start)なので、28px の
                  // ボタンをそのまま置くと 13px のテキスト行より低く見える。
                  // 上下中央を先頭列のチェックボックスの箱(上端から 9)に
                  // 揃えるだけ引き上げる
                  // (レイアウト高は変えたくないので Transform で見た目だけ)。
                  child: Transform.translate(
                    offset: const Offset(0, -5),
                    child: PronunciationButton(
                      word: word.word,
                      variant: PronunciationButtonVariant.tableIcon,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
