import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/components/app_outlined_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
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
              child: AppOutlinedButton(
                label: '忘れていた',
                textColor: AppColors.danger,
                hoverBackground: AppColors.dangerHoverBackground,
                verticalPadding: 11,
                borderRadius: 9,
                onPressed: onForgot,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppFilledButton(
                label: '覚えている',
                verticalPadding: 11,
                borderRadius: 9,
                onPressed: onKnew,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '「忘れていた」を選ぶと学習中リストに戻ります',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
