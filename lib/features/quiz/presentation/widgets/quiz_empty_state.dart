import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// クイズ対象(学習済み)が 0 件のときの空状態。
class QuizEmptyState extends ConsumerWidget {
  const QuizEmptyState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.quizEmpty,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 14),
          // iOS と同じく主ボタンにする(次に取る行動がこれしかないため)。
          AppFilledButton(
            label: context.l10n.toLearningList,
            fontSize: 13,
            onPressed: () => ref
                .read(mainPageProvider.notifier)
                .selectView(MainView.learning),
          ),
        ],
      ),
    );
  }
}
