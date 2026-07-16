import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 学習中 0 件の空状態。案内文 + 登録導線ボタン(プロトタイプ準拠)。
class LearningEmptyState extends ConsumerWidget {
  const LearningEmptyState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '学習中の単語はありません。\n単語を登録しましょう。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 14),
          AppFilledButton(
            label: '＋ 単語を登録',
            onPressed: () => ref
                .read(mainPageProvider.notifier)
                .selectView(MainView.registration),
          ),
        ],
      ),
    );
  }
}
