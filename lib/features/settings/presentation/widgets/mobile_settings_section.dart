import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// iOS 版の設定セクション(小見出し + 角丸カード)。
///
/// [rows] は区切り線を挟んで縦に並べる。カード外に置きたい要素
/// (入力欄・説明文など)がある場合は [child] を使う。
class MobileSettingsSection extends StatelessWidget {
  const MobileSettingsSection({
    required this.title,
    super.key,
    this.rows,
    this.child,
  }) : assert(
         (rows == null) != (child == null),
         'rows と child はどちらか一方だけを指定する',
       );

  final String title;
  final List<Widget>? rows;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: palette.textAlpha(50),
          ),
        ),
        const SizedBox(height: 8),
        if (child != null)
          child!
        else
          Container(
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.borderAlpha(10)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < rows!.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: palette.borderAlpha(7),
                      ),
                    ),
                  rows![i],
                ],
              ],
            ),
          ),
      ],
    );
  }
}
