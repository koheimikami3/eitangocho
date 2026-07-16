import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 学習済みチェック。変更を呼び出し側の onChanged に流す。
class LearnedCheckbox extends StatelessWidget {
  const LearnedCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.85,
      child: Checkbox(
        value: value,
        activeColor: AppColors.accent,
        onChanged: (checked) => onChanged(checked ?? false),
      ),
    );
  }
}
