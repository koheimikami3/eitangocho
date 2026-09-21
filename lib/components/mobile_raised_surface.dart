import 'package:eitangocho/components/mobile_pressable.dart';
import 'package:eitangocho/components/mobile_well.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// 影で浮かせた、押せる面(学習中カード・クイズの「忘れていた」ボタン)。
///
/// 押している間は浮きを消して内側に影を入れ、面が沈んだように見せる
/// (デザインの --elev → --elevPress + 地を --pressBg に)。
class MobileRaisedSurface extends StatelessWidget {
  const MobileRaisedSurface({
    required this.onTap,
    required this.borderRadius,
    required this.child,
    super.key,
    this.padding = EdgeInsets.zero,
  });

  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return MobilePressable(
      onTap: onTap,
      style: MobilePressStyle.card,
      builder: (context, pressed) => Container(
        decoration: BoxDecoration(
          color: pressed ? palette.pressBackground : palette.surface,
          borderRadius: borderRadius,
          boxShadow: pressed ? palette.elevationPressed : palette.elevation,
        ),
        child: CustomPaint(
          painter: pressed
              ? InsetShadowPainter(
                  shadows: palette.pressedInsetShadow,
                  borderRadius: borderRadius,
                )
              : null,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
