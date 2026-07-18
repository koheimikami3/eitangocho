import 'package:flutter/material.dart';

/// カードの出現アニメーション(プロトタイプの cardIn: opacity 0→1 +
/// translateY 4px→0、0.25s ease)。State 生成時(マウント時)に一度だけ再生される。
class CardIn extends StatelessWidget {
  const CardIn({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 4 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
