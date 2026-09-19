import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// iOS 版の設定カード内で行と行の間に挟む 1px の区切り線。
///
/// カードを組む [MobileSettingsSection] のほか、カードに複数行をまとめて
/// 渡す側(同期・書き出し)も同じ線を内側に持つため、ここに集約する。
class MobileSettingsDivider extends StatelessWidget {
  const MobileSettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 左右 14 はカード内の行のパディングと同じ。線を行のテキストに揃える。
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Divider(height: 1, thickness: 1, color: context.palette.rowLine),
    );
  }
}
