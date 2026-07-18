import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI 全体の拡大率を 0.1 刻みで変更するスライダー。変更は即保存・即反映。
class UiScaleSlider extends ConsumerWidget {
  const UiScaleSlider({required this.value, super.key});

  final double value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const divisions =
        ((AppDimensions.maxUiScale - AppDimensions.minUiScale) * 10);

    return Row(
      children: [
        Expanded(
          child: Slider(
            value: value.clamp(
              AppDimensions.minUiScale,
              AppDimensions.maxUiScale,
            ),
            min: AppDimensions.minUiScale,
            max: AppDimensions.maxUiScale,
            divisions: divisions.round(),
            activeColor: AppColors.accent,
            label: '${value.toStringAsFixed(1)}x',
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setUiScale(v),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${value.toStringAsFixed(1)}x',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
