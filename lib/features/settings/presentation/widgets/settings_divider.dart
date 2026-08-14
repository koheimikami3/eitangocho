import 'package:flutter/material.dart';

/// macOS 版の設定カード内で行と行の間に挟む 1px の区切り線。
///
/// カードを組む [SettingsCard] のほか、カードに複数行をまとめて渡す側
/// (同期・書き出し)も同じ線を内側に持つため、ここに集約する。
class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  /// 区切り線色(プロトタイプの rgba(0,0,0,0.07))。
  static const _color = Color(0x12000000);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      // 左右 14 はカード内の行のパディングと同じ。線を行のテキストに揃える。
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: _color,
    );
  }
}
