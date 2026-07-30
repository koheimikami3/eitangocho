import 'dart:math' as math;

import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// iOS 版の学習済みチェック(22x22・角丸 6)。
///
/// macOS 版の [LearnedCheckbox] より一回り大きく、色は [AppPalette] から引く。
/// タップ領域を稼ぐため、周囲のラベルごと囲んで使うことを想定している
/// (このウィジェット自身はチェック部分のみ)。
class MobileLearnedCheckbox extends StatelessWidget {
  const MobileLearnedCheckbox({required this.value, super.key});

  final bool value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: value ? palette.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: value ? palette.accent : palette.borderAlpha(25),
          width: 1.5,
        ),
      ),
      child: value ? const Center(child: _CheckMark()) : null,
    );
  }
}

/// チェックの ✓。
///
/// Icons.check は線が細く、22x22 の枠の中では小さく見える。デザインと同じ
/// 作り方(縦長の枠の右辺・下辺だけを 2px で描いて 45 度回す)にして、
/// 太さと大きさを揃える。
class _CheckMark extends StatelessWidget {
  const _CheckMark();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      // 回転させると視覚的な重心が下がるため、回転後の座標系で少し戻す。
      child: Transform.translate(
        offset: const Offset(-0.5, -1),
        child: Container(
          width: 7,
          height: 12,
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.white, width: 2),
              bottom: BorderSide(color: Colors.white, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
