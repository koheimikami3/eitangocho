import 'package:flutter/material.dart';

/// 設定画面の白カード。子の行を縦に並べ、行間に区切り線を挟む。
class SettingsCard extends StatelessWidget {
  const SettingsCard({required this.children, super.key});

  final List<Widget> children;

  /// カード枠線色(プロトタイプの rgba(0,0,0,0.10))。
  static const _border = Color(0x1A000000);

  /// 行間の区切り線色(プロトタイプの rgba(0,0,0,0.07))。
  static const _divider = Color(0x12000000);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: _divider,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}
