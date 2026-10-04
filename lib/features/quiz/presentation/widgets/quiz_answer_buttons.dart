import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/components/app_raised_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';

/// 答え表示後の回答ボタン列(忘れていた / 覚えている)+ 注記。
class QuizAnswerButtons extends StatelessWidget {
  const QuizAnswerButtons({
    required this.onForgot,
    required this.onKnew,
    super.key,
  });

  final VoidCallback onForgot;
  final VoidCallback onKnew;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              // iOS と同じく、枠線ではなく影で浮かせた面の副ボタンにする。
              child: AppRaisedButton(
                label: context.l10n.quizForgot,
                textColor: AppColors.danger,
                verticalPadding: 11,
                borderRadius: 9,
                onPressed: onForgot,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppFilledButton(
                label: context.l10n.quizRemembered,
                verticalPadding: 11,
                borderRadius: 9,
                onPressed: onKnew,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.quizForgotHint,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
