import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/app/widgets/toolbar_search_field.dart';
import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アプリシェルのツールバー。ビュータイトル・検索・登録ボタンを表示する。
class MainToolbar extends ConsumerWidget {
  const MainToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(mainPageProvider.select((s) => s.view));
    final title = switch (view) {
      MainView.allWords => '全単語',
      MainView.registration => '単語を登録',
    };

    return Container(
      height: AppDimensions.toolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          if (view == MainView.allWords) ...[
            const ToolbarSearchField(),
            const SizedBox(width: 10),
          ],
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
