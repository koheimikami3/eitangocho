import 'package:eitangocho/features/quiz/presentation/quiz_page_notifier.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_state.dart';
import 'package:eitangocho/features/quiz/presentation/widgets/quiz_answer_buttons.dart';
import 'package:eitangocho/features/quiz/presentation/widgets/quiz_card.dart';
import 'package:eitangocho/features/quiz/presentation/widgets/quiz_empty_state.dart';
import 'package:eitangocho/features/quiz/presentation/widgets/quiz_result_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// フラッシュクイズのビュー。phase で空状態 / 出題 / 完了画面を出し分ける。
/// 出題方向は現状 en→ja 固定(設定による切替は Phase 2 C3 で接続する)。
class QuizView extends ConsumerWidget {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizPageProvider);
    final notifier = ref.read(quizPageProvider.notifier);

    final Widget content = switch (state.phase) {
      QuizPhase.empty => const QuizEmptyState(),
      QuizPhase.done => QuizResultView(
        okCount: state.okCount,
        forgotWords: state.forgotWords,
      ),
      QuizPhase.active => _ActiveQuiz(state: state, notifier: notifier),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: content,
        ),
      ),
    );
  }
}

class _ActiveQuiz extends StatelessWidget {
  const _ActiveQuiz({required this.state, required this.notifier});

  final QuizPageState state;
  final QuizPageNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final word = state.questions[state.index];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizCard(
          progress: '${state.index + 1} / ${state.questions.length}',
          // en→ja 固定: 表面=英単語 + IPA、裏面=日本語訳。
          front: word.word,
          ipa: word.ipa,
          revealed: state.revealed,
          back: word.japanese,
          exampleEn: word.exampleEn,
          exampleJa: word.exampleJa,
          onReveal: notifier.reveal,
        ),
        if (state.revealed) ...[
          const SizedBox(height: 16),
          QuizAnswerButtons(
            onForgot: notifier.answerForgot,
            onKnew: notifier.answerKnew,
          ),
        ],
      ],
    );
  }
}
