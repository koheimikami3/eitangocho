import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// iOS 版の設定カード内に置く小見出し(「テーマ」「学習中カードの並び」等)。
///
/// 1 枚のカードに性質の違う設定をまとめるときだけ使う。直後の行との間に
/// 区切り線を入れないのは [MobileSettingsSection] 側の役目。
class MobileSettingsSubheader extends StatelessWidget {
  const MobileSettingsSubheader({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      // 下だけ詰めているのは、直下の行のパディングと合わせて
      // 見出しと中身が 1 組に見えるようにするため。
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: palette.textAlpha(45),
        ),
      ),
    );
  }
}
