import 'package:flutter/material.dart';

/// [MobilePressable] の押下演出。値はデザインの `:active` スタイル。
enum MobilePressStyle {
  /// 浮いた面(カード・面ボタン)。少し沈んで縮む。地と影は呼び出し側が
  /// builder の pressed で切り替える。
  card(scale: 0.972, opacity: 1, offsetY: 1),

  /// 主ボタン・ピル形ボタン。縮んで薄くなる。
  button(scale: 0.965, opacity: 0.72),

  /// タブバーの項目。
  tab(scale: 0.94, opacity: 0.6),

  /// リストの行。形は変えず、地の色だけを呼び出し側が変える。
  row(scale: 1, opacity: 1),

  /// シートの「キャンセル」「閉じる」など文字だけのボタン。薄くなるだけ。
  text(scale: 1, opacity: 0.4);

  const MobilePressStyle({
    required this.scale,
    required this.opacity,
    this.offsetY = 0,
  });

  final double scale;
  final double opacity;
  final double offsetY;
}

/// 押している間だけ見た目を変える iOS 版のタップ領域。
///
/// 縮小・透過・沈み込みは [style] に従ってここで行い、地の色や影の切り替えは
/// [builder] に pressed を渡して呼び出し側に任せる(面ごとに違うため)。
class MobilePressable extends StatefulWidget {
  const MobilePressable({
    required this.onTap,
    required this.builder,
    super.key,
    this.style = MobilePressStyle.button,
    this.behavior = HitTestBehavior.opaque,
  });

  final VoidCallback? onTap;
  final MobilePressStyle style;
  final HitTestBehavior behavior;
  final Widget Function(BuildContext context, bool pressed) builder;

  @override
  State<MobilePressable> createState() => _MobilePressableState();
}

class _MobilePressableState extends State<MobilePressable> {
  bool _pressed = false;

  // デザインの transition(0.09〜0.1s)に合わせる。
  static const _duration = Duration(milliseconds: 100);

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final enabled = widget.onTap != null;
    final pressed = enabled && _pressed;

    return GestureDetector(
      behavior: widget.behavior,
      onTap: widget.onTap,
      onTapDown: enabled ? (_) => _setPressed(true) : null,
      onTapUp: enabled ? (_) => _setPressed(false) : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      child: AnimatedOpacity(
        duration: _duration,
        opacity: pressed ? style.opacity : 1,
        child: AnimatedContainer(
          duration: _duration,
          curve: Curves.easeOut,
          transformAlignment: Alignment.center,
          transform: pressed
              ? (Matrix4.translationValues(0, style.offsetY, 0)
                  ..scaleByDouble(style.scale, style.scale, 1, 1))
              : Matrix4.identity(),
          child: widget.builder(context, pressed),
        ),
      ),
    );
  }
}
