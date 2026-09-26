import 'package:eitangocho/components/mobile_pressable.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// 影で浮かせた、押せる面(学習中カード・クイズの「忘れていた」ボタン)。
///
/// 押している間は縮むだけで、地・影は変えない。2.0.0 では浮きを消して内側に
/// 影を入れ、沈んだように見せていたが、2.2.0 でやめた(ユーザー判断)。
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
          color: palette.surface,
          borderRadius: borderRadius,
          boxShadow: palette.elevation,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
