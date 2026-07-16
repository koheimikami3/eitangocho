import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/app/widgets/sidebar_item.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/features/word/data/learning_words_provider.dart';
import 'package:eitangocho/features/word/data/word_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アプリシェルのサイドバー。プロトタイプの左ナビ相当。
class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(mainPageProvider.select((s) => s.view));
    final wordCount = ref.watch(wordListProvider).value?.length ?? 0;
    final learningCount = ref.watch(learningWordsProvider).length;
    final learnedCount = ref.watch(learnedWordsProvider).length;

    return Container(
      width: AppDimensions.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 52),
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 6, 0, 2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '単語帳',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          SidebarItem(
            label: '学習中',
            count: '$learningCount',
            selected: view == MainView.learning,
            onTap: () => ref
                .read(mainPageProvider.notifier)
                .selectView(MainView.learning),
          ),
          SidebarItem(
            label: '全単語',
            count: '$wordCount',
            selected: view == MainView.allWords,
            onTap: () => ref
                .read(mainPageProvider.notifier)
                .selectView(MainView.allWords),
          ),
          SidebarItem(
            label: 'フラッシュクイズ',
            count: '$learnedCount',
            selected: view == MainView.quiz,
            onTap: () => ref
                .read(mainPageProvider.notifier)
                .selectView(MainView.quiz),
          ),
          SidebarItem(
            label: '単語を登録',
            selected: view == MainView.registration,
            onTap: () => ref
                .read(mainPageProvider.notifier)
                .selectView(MainView.registration),
          ),
          const Spacer(),
          SidebarItem(
            label: '設定',
            selected: view == MainView.settings,
            onTap: () => ref
                .read(mainPageProvider.notifier)
                .selectView(MainView.settings),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x0F000000))),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ローカル DB に保存済み',
                    style: TextStyle(fontSize: 11, color: Color(0x59000000)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
