import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/components/labeled_text_field.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// ステップ 1: 英単語の入力(自動入力 or 手動入力へスキップ)。
class RegistrationInputStep extends StatelessWidget {
  const RegistrationInputStep({
    required this.wordController,
    required this.onAutoFill,
    required this.onSkip,
    super.key,
    this.errorMessage,
  });

  final TextEditingController wordController;
  final VoidCallback onAutoFill;
  final VoidCallback onSkip;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '英単語を入力すると、発音記号・日本語訳・例文などを辞書から自動取得します。',
          style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: LabeledTextField(
                label: '英単語 *',
                controller: wordController,
                hintText: 'apple',
                onSubmitted: (_) => onAutoFill(),
              ),
            ),
            const SizedBox(width: 10),
            AppFilledButton(label: '自動入力', onPressed: onAutoFill),
          ],
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            errorMessage!,
            style: const TextStyle(fontSize: 12, color: AppColors.danger),
          ),
        ],
        const SizedBox(height: 14),
        _SkipLink(onTap: onSkip),
      ],
    );
  }
}

/// 「スキップして手動で入力する」リンク。
///
/// hover での下線は 2.2.0 でやめた(文字色とカーソルで押せると分かるため。
/// ユーザー判断)。
class _SkipLink extends StatelessWidget {
  const _SkipLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: const Text(
          'スキップして手動で入力する',
          style: TextStyle(fontSize: 13, color: AppColors.accent),
        ),
      ),
    );
  }
}
