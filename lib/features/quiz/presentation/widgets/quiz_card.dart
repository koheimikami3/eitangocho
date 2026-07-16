import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// クイズの出題カード(幅 480 中央)。進捗・表面・IPA・答え表示ボタン、
/// 答え表示後は区切り線 + 裏面 + 例文を表示する。
class QuizCard extends StatelessWidget {
  const QuizCard({
    required this.progress,
    required this.front,
    required this.ipa,
    required this.revealed,
    required this.back,
    required this.exampleEn,
    required this.exampleJa,
    required this.onReveal,
    super.key,
  });

  final String progress;
  final String front;

  /// 表面に出す IPA(空なら非表示。ja→en のときは空で渡す)。
  final String ipa;
  final bool revealed;
  final String back;
  final String exampleEn;
  final String exampleJa;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    final hasExample = exampleEn.trim().isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          progress,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 44),
          constraints: const BoxConstraints(minHeight: 220),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x1A000000)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 12,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                front,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (ipa.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  ipa,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Menlo',
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
              if (revealed) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(top: 14),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0x14000000))),
                  ),
                  child: Text(
                    back,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (hasExample) ...[
                  const SizedBox(height: 10),
                  Text(
                    '$exampleEn\n$exampleJa',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        if (!revealed) ...[
          const SizedBox(height: 16),
          AppFilledButton(label: '答えを表示', onPressed: onReveal),
        ],
      ],
    );
  }
}
