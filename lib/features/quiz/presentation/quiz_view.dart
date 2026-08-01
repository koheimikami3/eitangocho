import 'package:eitangocho/features/quiz/presentation/quiz_page_notifier.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_state.dart';
import 'package:eitangocho/features/quiz/presentation/widgets/quiz_answer_buttons.dart';
import 'package:eitangocho/features/quiz/presentation/widgets/quiz_card.dart';
import 'package:eitangocho/features/quiz/presentation/widgets/quiz_empty_state.dart';
import 'package:eitangocho/features/quiz/presentation/widgets/quiz_result_view.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/quiz_direction.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// フラッシュクイズのビュー。phase で空状態 / 出題 / 完了画面を出し分ける。
/// 出題方向は設定 quizDirection に従う(ja→en のときは表面=訳・裏面=英単語・IPA 非表示)。
class QuizView extends ConsumerWidget {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizPageProvider);
    final notifier = ref.read(quizPageProvider.notifier);
    // ロード前は既定(en→ja)でフォールバック。
    final direction =
        ref.watch(settingsProvider).value?.quizDirection ??
        const SettingsState().quizDirection;

    final Widget content = switch (state.phase) {
      QuizPhase.empty => const QuizEmptyState(),
      QuizPhase.done => QuizResultView(
        okCount: state.okCount,
        forgotWords: state.forgotWords,
      ),
      QuizPhase.active => _ActiveQuiz(
        state: state,
        notifier: notifier,
        direction: direction,
      ),
    };

    // プロトタイプ準拠で画面全体の縦横中央に置く。コンテンツが画面より
    // 高いとき(答え表示 + 長い例文等)はスクロールにフォールバックする。
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 40,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: content,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActiveQuiz extends StatelessWidget {
  const _ActiveQuiz({
    required this.state,
    required this.notifier,
    required this.direction,
  });

  final QuizPageState state;
  final QuizPageNotifier notifier;
  final QuizDirection direction;

  @override
  Widget build(BuildContext context) {
    final word = state.questions[state.index];
    // en→ja: 表面=英単語 + IPA、裏面=訳。ja→en: 表面=訳(IPA なし)、裏面=英単語。
    final isJaToEn = direction == QuizDirection.jaToEn;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        if (!state.revealed) ...{
          const SingleActivator(LogicalKeyboardKey.space): notifier.reveal,
          const SingleActivator(LogicalKeyboardKey.enter): notifier.reveal,
          const SingleActivator(LogicalKeyboardKey.numpadEnter):
              notifier.reveal,
        } else ...{
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
              notifier.answerForgot(),
          const SingleActivator(LogicalKeyboardKey.digit1): () =>
              notifier.answerForgot(),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
              notifier.answerKnew(),
          const SingleActivator(LogicalKeyboardKey.digit2): () =>
              notifier.answerKnew(),
        },
      },
      child: Focus(
        autofocus: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QuizCard(
              progress: '${state.index + 1} / ${state.questions.length}',
              front: isJaToEn ? word.japanese : word.word,
              ipa: isJaToEn ? '' : word.ipa,
              revealed: state.revealed,
              back: isJaToEn ? word.word : word.japanese,
              exampleEn: word.exampleEn,
              exampleJa: word.exampleJa,
              onReveal: notifier.reveal,
              englishWord: word.word,
              pronunciationOnFront: !isJaToEn,
            ),
            if (state.revealed) ...[
              const SizedBox(height: 16),
              QuizAnswerButtons(
                onForgot: notifier.answerForgot,
                onKnew: notifier.answerKnew,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
