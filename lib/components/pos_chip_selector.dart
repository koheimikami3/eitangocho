import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';

/// 品詞の複数選択チップ(横並び・折り返し)。
class PosChipSelector extends StatelessWidget {
  const PosChipSelector({
    required this.selected,
    required this.onToggle,
    super.key,
  });

  final Set<PartOfSpeech> selected;
  final ValueChanged<PartOfSpeech> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final pos in PartOfSpeech.values)
          _Chip(
            pos: pos,
            isSelected: selected.contains(pos),
            onTap: () => onToggle(pos),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.pos,
    required this.isSelected,
    required this.onTap,
  });

  final PartOfSpeech pos;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 選択中は品詞バッジと同じ配色にし、文字色で縁取る
    // (iOS の MobilePosChipSelector と揃える。2.2.0 で単色の青から変更)。
    final background = pos.badgeBackground;
    final foreground = pos.badgeForeground;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? background : Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isSelected ? foreground : AppColors.inputBorder,
          ),
        ),
        child: Text(
          pos.label(context.l10n),
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? foreground : const Color(0xA6000000),
          ),
        ),
      ),
    );
  }
}
