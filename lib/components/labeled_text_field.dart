import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// ラベル付き入力欄。textarea 相当は [maxLines] を 2 以上にして使う。
/// [maxLines] に null を渡すと内容量に応じて欄が伸びる([minLines] が下限)。
/// [trailing] にはラベル横の補助ウィジェット(Phase 3 の自動入力バッジ等)を置ける。
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    required this.label,
    required this.controller,
    super.key,
    this.trailing,
    this.minLines,
    this.maxLines = 1,
    this.hintText = '手動で入力してください',
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final Widget? trailing;
  final int? minLines;
  final int? maxLines;
  final String hintText;

  /// Enter キー確定時のコールバック(ステップ 1 の自動入力発火等)
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 6), trailing!],
          ],
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          onSubmitted: onSubmitted,
          // 既定のカーソルは行高いっぱい・太めで存在感が強いため、
          // 少し低く・細くする。
          cursorHeight: 16,
          cursorWidth: 1,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            // 既定のヒント色は濃く入力済みの値に見えるため、明示的に薄くする
            hintStyle: const TextStyle(color: AppColors.textDisabled),
            // 自動入力ボタン等と高さを揃えつつ、上下に余裕を持たせる。
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            // フォーカス時も枠色は変えず通常時と同じにする
            // (Material 既定の太い黒枠が出るのを防ぐ)。
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
          ),
        ),
      ],
    );
  }
}
