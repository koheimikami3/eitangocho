import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';

/// iOS 版の品詞バッジ(ピル)。
///
/// macOS 版の [PosBadge] と違い、色は [AppPalette] から引く
/// (ダーク時に別配色を使うため。enum が持つ色定数はライト固定)。
/// 色は先頭の品詞のものを使い、ラベルは全品詞を「・」で連結する。
class MobilePosBadge extends StatelessWidget {
  const MobilePosBadge({required this.partsOfSpeech, super.key});

  final List<PartOfSpeech> partsOfSpeech;

  @override
  Widget build(BuildContext context) {
    final pos = partsOfSpeech.isEmpty
        ? PartOfSpeech.other
        : partsOfSpeech.first;
    final (background, foreground) = context.palette.posBadge(pos);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        partsOfSpeech.isEmpty
            ? pos.label(context.l10n)
            : partsOfSpeech.joinedLabel(context.l10n),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}
