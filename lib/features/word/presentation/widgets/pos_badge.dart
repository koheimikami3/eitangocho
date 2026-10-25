import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';

/// 品詞バッジ(ピル)。品詞ごとに 1 枚ずつ、その品詞の色で並べる。
///
/// 全品詞を 1 枚に連結していた頃は、表の狭い列で品詞が多いと 1 枚の中で
/// 文字が折り返して塊になっていた。1 枚ずつなら、収まらない分は
/// ピルの形のまま次の行に回る。
class PosBadge extends StatelessWidget {
  const PosBadge({required this.partsOfSpeech, super.key});

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
    // 品詞の色は iOS と共通(ライト / ダークとも AppPalette.posBadge が持つ)。
    final (background, foreground) = context.palette.posBadge(pos);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        pos.label(context.l10n),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}
