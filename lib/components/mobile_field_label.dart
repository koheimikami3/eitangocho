import 'package:eitangocho/components/mobile_auto_fill_badge.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// iOS 版フォームの項目名。[autoFilled] のときは脇に「自動入力」バッジを出す。
///
/// 入力欄(MobileLabeledField)と品詞チップの見出しで同じ見た目にするため共通化。
class MobileFieldLabel extends StatelessWidget {
  const MobileFieldLabel({
    required this.label,
    super.key,
    this.autoFilled = false,
  });

  final String label;
  final bool autoFilled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: context.palette.textAlpha(60),
          ),
        ),
        if (autoFilled) ...[
          const SizedBox(width: 6),
          const MobileAutoFillBadge(),
        ],
      ],
    );
  }
}
