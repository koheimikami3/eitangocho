import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';

/// iOS 版の品詞バッジ(ピル)。品詞ごとに 1 枚ずつ、その品詞の色で並べる。
///
/// macOS 版の [PosBadge] と違い、色は [AppPalette] から引く
/// (ダーク時に別配色を使うため。enum が持つ色定数はライト固定)。
/// 1 枚ずつにする理由は [PosBadge] と同じ(収まらない分はピルの形のまま
/// 次の行に回す)。
class MobilePosBadge extends StatelessWidget {
  const MobilePosBadge({required this.partsOfSpeech, super.key});

  final List<PartOfSpeech> partsOfSpeech;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final pos
            in partsOfSpeech.isEmpty
                ? const [PartOfSpeech.other]
                : partsOfSpeech)
          _Pill(pos: pos),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.pos});

  final PartOfSpeech pos;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = context.palette.posBadge(pos);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        pos.label(context.l10n),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}
