import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:flutter/material.dart';

/// iOS 版のラベル付き入力欄。
///
/// [autoFilled] が true のときはラベル脇に「自動入力」バッジを出す
/// (単語登録で辞書から埋まった項目を示す)。
class MobileLabeledField extends StatelessWidget {
  const MobileLabeledField({
    required this.label,
    required this.controller,
    super.key,
    this.hintText = '手動で入力してください',
    this.maxLines = 1,
    this.autoFilled = false,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final bool autoFilled;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: BorderSide(color: palette.borderAlpha(15)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: palette.textAlpha(60),
              ),
            ),
            if (autoFilled) ...[
              const SizedBox(width: 6),
              const MobileAutoFillBadge(),
            ],
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onSubmitted: onSubmitted,
          cursorWidth: AppDimensions.mobileCursorWidth,
          cursorColor: palette.accent,
          // iOS で入力欄をタップしたときに拡大されないよう 16px 以上にする。
          style: TextStyle(fontSize: 16, color: palette.text),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: TextStyle(color: palette.textAlpha(30)),
            filled: true,
            fillColor: palette.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
        ),
      ],
    );
  }
}

/// 辞書から自動入力された項目を示す小さなバッジ。
class MobileAutoFillBadge extends StatelessWidget {
  const MobileAutoFillBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: palette.autoFillBadgeBackground,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '自動入力',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: palette.autoFillBadgeForeground,
        ),
      ),
    );
  }
}
