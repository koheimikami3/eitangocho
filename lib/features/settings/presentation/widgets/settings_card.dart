import 'package:eitangocho/features/settings/presentation/widgets/settings_divider.dart';
import 'package:flutter/material.dart';

/// 設定画面の白カード。子の行を縦に並べ、行間に区切り線を挟む。
class SettingsCard extends StatelessWidget {
  const SettingsCard({required this.children, super.key});

  final List<Widget> children;

  /// カード枠線色(プロトタイプの rgba(0,0,0,0.10))。
  static const _border = Color(0x1A000000);

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
            if (i > 0) const SettingsDivider(),
            children[i],
          ],
        ],
      ),
    );
  }
}
