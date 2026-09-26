import 'package:eitangocho/components/mobile_pressable.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:flutter/material.dart';

/// iOS 版の品詞選択チップ(複数選択可)。
///
/// 選択中はその品詞のバッジ色(文字色で縁取り)、未選択は面の色 + 淡い縁。
class MobilePosChipSelector extends StatelessWidget {
  const MobilePosChipSelector({
    required this.selected,
    required this.onToggle,
    super.key,
  });

  final Set<PartOfSpeech> selected;
  final ValueChanged<PartOfSpeech> onToggle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    // 5 つを同じ幅で 1 行に並べる(折り返さない。iPhone SE 幅でも収まる)。
    return Row(
      children: [
        for (final (i, pos) in PartOfSpeech.values.indexed) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: () {
              final isSelected = selected.contains(pos);
              final (background, foreground) = palette.posBadge(pos);
              return MobilePressable(
                onTap: () => onToggle(pos),
                builder: (context, _) => AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? background : palette.surface,
                    borderRadius: BorderRadius.circular(99),
                    // 選択中は文字色で縁取り、未選択は淡い縁 + 小さな影で
                    // 「押せる面」に見せる。縁の濃さは入力欄の枠
                    // (AppPalette.wellShadow)と揃える。
                    border: Border.all(
                      color: isSelected ? foreground : palette.borderAlpha(28),
                    ),
                    boxShadow: isSelected
                        ? null
                        : const [
                            BoxShadow(
                              color: Color(0x0F101828), // rgba(16,24,40,0.06)
                              blurRadius: 1.5,
                              offset: Offset(0, 1),
                            ),
                          ],
                  ),
                  child: Text(
                    pos.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? foreground : palette.textAlpha(55),
                    ),
                  ),
                ),
              );
            }(),
          ),
        ],
      ],
    );
  }
}
