import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/domain/learning_card_layout.dart';
import 'package:flutter/material.dart';

/// 「学習中カードの並び」の選択肢に添えるミニプレビュー。
/// カードに見立てた枠を列数のぶんだけ並べる(2 列は細い枠 2 つ、1 列は太い枠 1 つ)。
class MobileCardLayoutPreview extends StatelessWidget {
  const MobileCardLayoutPreview({required this.layout, super.key});

  final LearningCardLayout layout;

  static const _height = 16.0;
  static const _gap = 2.0;
  static const _totalWidth = 24.0;

  @override
  Widget build(BuildContext context) {
    final color = context.palette.textAlpha(30);
    final columns = layout.columns;
    // どの選択肢でも全体の幅を揃える(枠の数だけ変える)。
    final width = (_totalWidth - _gap * (columns - 1)) / columns;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < columns; i++) ...[
          if (i > 0) const SizedBox(width: _gap),
          Container(
            width: width,
            height: _height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: color, width: 1.5),
            ),
          ),
        ],
      ],
    );
  }
}
