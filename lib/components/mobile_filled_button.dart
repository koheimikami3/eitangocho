import 'package:eitangocho/components/mobile_pressable.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// iOS 版の主ボタン(アクセント色のグラデーション + 白文字)。
///
/// macOS 版の [AppFilledButton] に相当する。寸法はボタンごとにデザインの値が
/// 違うため、既定値はクイズ・結果画面の全幅ボタン(15px・上下 14・角丸 12)にして
/// 他は呼び出し側で上書きする。
class MobileFilledButton extends StatelessWidget {
  const MobileFilledButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w600,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 12,
  });

  final String label;
  final VoidCallback onPressed;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return MobilePressable(
      onTap: onPressed,
      builder: (context, _) => Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: palette.buttonGradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: palette.buttonShadow,
        ),
        child: Text(
          label,
          // 全幅で置かれたときも中央に寄せる。
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
