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
      child: value
          ? const Icon(Icons.check, size: 15, color: Colors.white)
          : null,
    );
  }
}
