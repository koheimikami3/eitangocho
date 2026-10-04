import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';

/// 品詞バッジ(ピル)。色は先頭の品詞のものを使う
/// (プロトタイプの pillFor が最初にマッチした品詞の色を使う挙動に準拠)。
class PosBadge extends StatelessWidget {
  const PosBadge({required this.partsOfSpeech, super.key});

  final List<PartOfSpeech> partsOfSpeech;

  @override
  Widget build(BuildContext context) {
    final pos = partsOfSpeech.isEmpty
        ? PartOfSpeech.other
        : partsOfSpeech.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: pos.badgeBackground,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        partsOfSpeech.isEmpty
            ? pos.label(context.l10n)
            : partsOfSpeech.joinedLabel(context.l10n),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: pos.badgeForeground,
        ),
      ),
    );
  }
}
