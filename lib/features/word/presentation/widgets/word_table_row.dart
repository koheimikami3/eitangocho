import 'package:eitangocho/components/pronunciation_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/presentation/widgets/learned_checkbox.dart';
import 'package:eitangocho/features/word/presentation/widgets/pos_badge.dart';
import 'package:flutter/material.dart';

/// 全単語テーブルの 1 行。
class WordTableRow extends StatefulWidget {
  const WordTableRow({
    required this.word,
    required this.onToggleLearned,
    required this.onTap,
    required this.onSecondaryTapUp,
    super.key,
  });

  final Word word;
  final ValueChanged<bool> onToggleLearned;
  final VoidCallback onTap;
  final void Function(TapUpDetails details) onSecondaryTapUp;

  @override
  State<WordTableRow> createState() => _WordTableRowState();
}

class _WordTableRowState extends State<WordTableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final hasExample = word.exampleEn.trim().isNotEmpty;
    final background = _isHovered
        ? AppColors.rowHoverBackground
        : (word.isLearned ? AppColors.learnedRowBackground : Colors.white);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTapUp: widget.onSecondaryTapUp,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            border: const Border(
              bottom: BorderSide(color: Color(0x0F000000)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64,
                // 行上端の単語テキストと視覚的に揃うよう少し下げる。
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
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
                child: Text(
                  word.word,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 130,
                child: Text(
                  word.ipa,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Menlo',
                    color: Color(0x80000000),
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
                  word.japanese,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xBF000000),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: hasExample
                    ? Text(
                        '${word.exampleEn}\n${word.exampleJa}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      )
                    : const Text(
                        '例文なし',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textDisabled,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 56,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PronunciationButton(
                    word: word.word,
                    audioUrl: word.audioUrl,
                    size: 26,
                    compactLink: true,
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
