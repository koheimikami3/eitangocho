import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI 全体の拡大率を 0.1 刻みで変更するスライダー行。変更は即保存・即反映。
/// プロトタイプのカスタムスライダー意匠(トラック 4px・白 thumb 17px)を
/// フル自作せず SliderTheme + 自作 thumb 形状で再現する。
class UiScaleSlider extends ConsumerWidget {
  const UiScaleSlider({required this.value, super.key});

  final double value;

  /// 未到達側のトラック色(プロトタイプの rgba(0,0,0,0.12))。
  static const _inactiveTrack = Color(0x1F000000);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const divisions =
        ((AppDimensions.maxUiScale - AppDimensions.minUiScale) * 10);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          const Text(
            '表示サイズ',
            style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                activeTrackColor: AppColors.accent,
                inactiveTrackColor: _inactiveTrack,
                thumbShape: const _CircleThumbShape(),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: SizedBox(
                height: 26,
                child: Slider(
                  value: value.clamp(
                    AppDimensions.minUiScale,
                    AppDimensions.maxUiScale,
                  ),
                  min: AppDimensions.minUiScale,
                  max: AppDimensions.maxUiScale,
                  divisions: divisions.round(),
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setUiScale(v),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 34,
            child: Text(
              '${value.toStringAsFixed(1)}x',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

/// プロトタイプの thumb(17x17 白円・薄い枠線+影)。
class _CircleThumbShape extends SliderComponentShape {
  const _CircleThumbShape();

  static const _radius = 8.5;
  static const _borderColor = Color(0x1F000000); // rgba(0,0,0,0.12)

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
      center + const Offset(0, 1),
      _radius,
      Paint()
        ..color =
            const Color(0x4D000000) // 影: rgba(0,0,0,0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
    canvas.drawCircle(center, _radius, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      _radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = _borderColor,
    );
  }
}
