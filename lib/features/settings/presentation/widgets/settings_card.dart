import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_divider.dart';
import 'package:flutter/material.dart';

/// 設定画面の白カード。子の行を縦に並べ、行間に区切り線を挟む。
class SettingsCard extends StatelessWidget {
  const SettingsCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      // iOS の設定セクションと同じく枠線なし + 淡い影(2.2.0)。
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.mobileCardRadius),
        boxShadow: AppPalette.light.elevation,
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
