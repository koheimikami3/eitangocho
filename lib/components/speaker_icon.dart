import 'package:flutter/material.dart';

/// 発音ボタンのスピーカーアイコン(機能横断コンポーネント)。
///
/// Material の `Icons.volume_up` は音波が 3 本でデザインと形が違うため、
/// デザインの SVG(16×16 viewBox の 2 パス)をそのまま [CustomPainter] で描く。
/// 塗りの本体 + 線の音波 1 本という構成で、線幅もアイコンサイズに追従させる。
class SpeakerIcon extends StatelessWidget {
  const SpeakerIcon({required this.size, required this.color, super.key});

  /// 一辺の長さ(デザインの svg width / height)。
  final double size;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _SpeakerIconPainter(color: color)),
    );
  }
}

class _SpeakerIconPainter extends CustomPainter {
  const _SpeakerIconPainter({required this.color});

  final Color color;

  /// デザインの SVG の viewBox。この座標系で組んでから実サイズに拡大する。
  static const _viewBox = 16.0;

  /// 音波の線幅(viewBox 基準)。
  static const _waveStrokeWidth = 1.3;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBox;
    canvas
      ..save()
      ..scale(scale);

    // 本体: M3 6.2v3.6h2.5L8.7 12.3V3.7L5.5 6.2H3z
    final body = Path()
      ..moveTo(3, 6.2)
      ..lineTo(3, 9.8)
      ..lineTo(5.5, 9.8)
      ..lineTo(8.7, 12.3)
      ..lineTo(8.7, 3.7)
      ..lineTo(5.5, 6.2)
      ..close();
    canvas.drawPath(body, Paint()..color = color);

    // 音波: M10.8 5.8c0.8 0.5 1.3 1.3 1.3 2.2s-0.5 1.7-1.3 2.2
    // 2 つ目は SVG の smooth curve(s)で、1 つ目の制御点を終点で反転した
    // 点が第 1 制御点になる。Path に相当する API が無いため展開して書く。
    final wave = Path()
      ..moveTo(10.8, 5.8)
      ..cubicTo(11.6, 6.3, 12.1, 7.1, 12.1, 8)
      ..cubicTo(12.1, 8.9, 11.6, 9.7, 10.8, 10.2);
    canvas.drawPath(
      wave,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _waveStrokeWidth
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SpeakerIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
