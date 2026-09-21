import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 内側の影で沈めた角丸の面(デザインの box-shadow: inset 相当)。
///
/// Flutter の [BoxShadow] は inset を描けないため、[InsetShadowPainter] で
/// 面の内側に影を描く。入力欄・訳の表示枠(`AppPalette.wellShadow`)と、
/// 押下中のカード(`AppPalette.pressedInsetShadow`)で使う。
class MobileWell extends StatelessWidget {
  const MobileWell({
    required this.color,
    required this.shadows,
    required this.borderRadius,
    required this.child,
    super.key,
    this.padding = EdgeInsets.zero,
  });

  final Color color;

  /// 内側に描く影。[BoxShadow] を「inset の影」の値の入れ物として流用する
  /// (spreadRadius は内側へ食い込む幅。blur 0・spread 1 で 1px の内枠になる)。
  final List<BoxShadow> shadows;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: borderRadius),
      child: CustomPaint(
        painter: InsetShadowPainter(
          shadows: shadows,
          borderRadius: borderRadius,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// 角丸矩形の内側に影を描く。
///
/// 面の外側を大きな矩形でくり抜いた形(面の穴が開いた板)をぼかして描き、
/// 面の形でクリップする。板の穴を offset だけずらすと、その反対側の縁に
/// 影が溜まる(CSS の inset shadow と同じ見え方)。
class InsetShadowPainter extends CustomPainter {
  const InsetShadowPainter({required this.shadows, required this.borderRadius});

  final List<BoxShadow> shadows;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = borderRadius.toRRect(Offset.zero & size);
    canvas
      ..save()
      ..clipRRect(rrect);
    for (final shadow in shadows) {
      final hole = rrect.shift(shadow.offset).deflate(shadow.spreadRadius);
      // 板の外周はぼかしが面に回り込まない程度に十分広く取る。
      final margin = shadow.blurRadius * 2 + shadow.offset.distance + 1;
      final path = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(rrect.outerRect.inflate(margin))
        ..addRRect(hole);
      final paint = Paint()..color = shadow.color;
      if (shadow.blurRadius > 0) {
        paint.maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          Shadow.convertRadiusToSigma(shadow.blurRadius),
        );
      }
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(InsetShadowPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius ||
      !listEquals(oldDelegate.shadows, shadows);
}
