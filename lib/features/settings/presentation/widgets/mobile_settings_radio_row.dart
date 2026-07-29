import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// iOS 版の設定ラジオ行(丸いラジオ + ラベル)。行全体がタップ領域。
class MobileSettingsRadioRow extends StatelessWidget {
  const MobileSettingsRadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// 行の右端に置く補助表示(列数のプレビュー等)。無ければラベルだけ。
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? palette.accent : Colors.transparent,
                border: Border.all(
                  color: selected ? palette.accent : palette.borderAlpha(25),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Center(
                      child: SizedBox(
                        width: 7,
                        height: 7,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: palette.text),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
