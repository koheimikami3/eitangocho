import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/components/app_outlined_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// クイズ完了画面(復習完了・成績・忘れていた単語一覧・導線)。
class QuizResultView extends ConsumerWidget {
  const QuizResultView({
    required this.okCount,
    required this.forgotWords,
    super.key,
  });

  final int okCount;
  final List<Word> forgotWords;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '復習完了',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '覚えている $okCount語 / 忘れていた ${forgotWords.length}語',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        if (forgotWords.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ForgotList(words: forgotWords),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppFilledButton(
                label: 'もう一度',
                onPressed: () =>
                    ref.read(quizPageProvider.notifier).startQuiz(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppOutlinedButton(
                label: '学習中リストへ',
                onPressed: () => ref
                    .read(mainPageProvider.notifier)
                    .selectView(MainView.learning),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ForgotList extends StatelessWidget {
  const _ForgotList({required this.words});

  final List<Word> words;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1A000000)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.tableHeaderBackground,
              border: Border(bottom: BorderSide(color: Color(0x12000000))),
            ),
            child: const Text(
              '忘れていた単語(学習中リストに戻りました)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          for (final word in words)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0x0D000000))),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      word.word,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      word.japanese,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
