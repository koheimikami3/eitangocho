import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:flutter/material.dart';

/// iOS 版の品詞選択チップ(複数選択可)。
///
/// 選択中はその品詞のバッジ色、未選択は淡い枠のみ。
class MobilePosChipSelector extends StatelessWidget {
  const MobilePosChipSelector({
    required this.selected,
    required this.onToggle,
    super.key,
  });

  final Set<PartOfSpeech> selected;
  final ValueChanged<PartOfSpeech> onToggle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final pos in PartOfSpeech.values)
          () {
            final isSelected = selected.contains(pos);
            final (background, foreground) = palette.posBadge(pos);
            return GestureDetector(
              onTap: () => onToggle(pos),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? background : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: isSelected ? background : palette.borderAlpha(15),
                  ),
                ),
                child: Text(
                  pos.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? foreground : palette.textAlpha(60),
                  ),
                ),
              ),
            );
          }(),
      ],
    );
  }
}
