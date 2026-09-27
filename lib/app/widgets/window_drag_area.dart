import 'package:eitangocho/utils/window_control.dart';
import 'package:flutter/material.dart';

/// macOS のタイトルバーの代わりになる領域。ドラッグでウィンドウを動かし、
/// ダブルクリックで拡大 / 元に戻す(システム設定に従う)。
///
/// ボタンなどを含む帯では、中身の後ろに `Positioned.fill` で敷く。前面の
/// 部品が当たった所ではこちらに届かないので、空いている所だけが反応する
/// (中身をこれで包むと、ダブルクリック判定のためにボタンのタップが遅れる)。
class WindowDragArea extends StatelessWidget {
  const WindowDragArea({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) => startWindowDrag(),
      onDoubleTap: handleTitleBarDoubleClick,
      child: child,
    );
  }
}
