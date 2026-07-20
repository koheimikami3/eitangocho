import 'dart:math' as math;

import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 学習済みチェック。変更を呼び出し側の onChanged に流す。
/// プロトタイプのカスタムチェックボックス意匠(16x16 角丸・白レ点)を再現する。
class LearnedCheckbox extends StatelessWidget {
  const LearnedCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  /// 未チェック時の枠線色(プロトタイプの rgba(0,0,0,0.25))。
  static const _uncheckedBorder = Color(0x40000000);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      // 親から tight 制約が来ても既定サイズを保つよう Align で制約を吸収する。
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: 1,
        heightFactor: 1,
        // 標準 Checkbox 撤去で失われたヒット領域を padding で補償する。
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: value ? AppColors.accent : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: value
                  ? Border.all(color: AppColors.accent)
                  : Border.all(color: _uncheckedBorder, width: 1.5),
            ),
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: value ? 1 : 0,
                child: Transform.translate(
                  offset: const Offset(-0.5, -1.5),
                  child: Transform.rotate(
                    angle: math.pi / 4,
                    // レ点は L 字(右+下の白ボーダー)を 45 度回転させて描く。
                    child: Container(
                      width: 6,
                      height: 11,
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.white, width: 2.5),
                          bottom: BorderSide(color: Colors.white, width: 2.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
