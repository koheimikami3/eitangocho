import 'package:eitangocho/components/mobile_filled_button.dart';
import 'package:eitangocho/components/mobile_raised_surface.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_notifier.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_state.dart';
import 'package:eitangocho/features/quiz/presentation/widgets/mobile_quiz_card.dart';
import 'package:eitangocho/features/quiz/presentation/widgets/mobile_quiz_empty_state.dart';
import 'package:eitangocho/features/quiz/presentation/widgets/mobile_quiz_result_view.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/quiz_direction.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版のフラッシュクイズ。
///
/// 出題ロジックは macOS 版と同じ [QuizPageNotifier] を共有し、見た目と
/// 操作(キーボードショートカットを持たない)だけが異なる。
class QuizViewMobile extends ConsumerWidget {
  const QuizViewMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizPageProvider);
    final notifier = ref.read(quizPageProvider.notifier);
    // ロード前は既定(en→ja)でフォールバック。
    final direction =
        ref.watch(settingsProvider).value?.quizDirection ??
        const SettingsState().quizDirection;

    final Widget content = switch (state.phase) {
      QuizPhase.empty => const MobileQuizEmptyState(),
      QuizPhase.done => MobileQuizResultView(
        okCount: state.okCount,
        forgotWords: state.forgotWords,
      ),
      QuizPhase.active => _ActiveQuiz(
        state: state,
        notifier: notifier,
        direction: direction,
      ),
    };

    // 縦中央に置き、答え表示で背が伸びたときはスクロールにフォールバックする。
    return LayoutBuilder(
      builder: (context, constraints) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 40 - bottomInset,
            ),
            child: Center(child: content),
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
    final palette = context.palette;
    final word = state.questions[state.index];
    // en→ja: 表面=英単語 + IPA、裏面=訳。ja→en: 表面=訳(IPA なし)、裏面=英単語。
    final isJaToEn = direction == QuizDirection.jaToEn;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${state.index + 1} / ${state.questions.length}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: palette.textAlpha(45)),
        ),
        const SizedBox(height: 16),
        MobileQuizCard(
          front: isJaToEn ? word.meaning : word.word,
          ipa: isJaToEn ? '' : word.ipa,
          revealed: state.revealed,
          back: isJaToEn ? word.word : word.meaning,
          exampleEn: word.exampleEn,
          exampleTranslation: word.exampleTranslation,
          englishWord: word.word,
          pronunciationOnFront: !isJaToEn,
        ),
        const SizedBox(height: 16),
        if (!state.revealed)
          MobileFilledButton(
            label: context.l10n.showAnswer,
            onPressed: notifier.reveal,
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: _SecondaryButton(
                  label: context.l10n.quizForgot,
                  color: palette.danger,
                  onTap: notifier.answerForgot,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MobileFilledButton(
                  label: context.l10n.quizRemembered,
                  onPressed: notifier.answerKnew,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.quizForgotHint,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: palette.textAlpha(38)),
          ),
        ],
      ],
    );
  }
}

/// 影で浮かせた面のボタン(クイズの副操作)。
class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onTap,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return MobileRaisedSurface(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(14),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color ?? palette.text,
        ),
      ),
    );
  }
}
