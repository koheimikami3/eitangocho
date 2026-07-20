import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/components/app_outlined_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
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
          const Text(
            '復習対象の単語がまだありません。\n単語を学習済みにするとここに表示されます。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 14),
          AppOutlinedButton(
            label: '学習中リストへ',
            textColor: AppColors.accent,
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
