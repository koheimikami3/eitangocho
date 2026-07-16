import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
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
            label: pos.label,
            isSelected: selected.contains(pos),
            onTap: () => onToggle(pos),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.inputBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xA6000000),
          ),
        ),
      ),
    );
  }
}
