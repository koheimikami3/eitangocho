import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/app/widgets/sidebar_item.dart';
import 'package:eitangocho/app/widgets/window_drag_area.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_notifier.dart';
import 'package:eitangocho/features/word/data/learning_words_provider.dart';
import 'package:eitangocho/features/word/data/word_list_provider.dart';
import 'package:eitangocho/utils/l10n_context.dart';
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
          // 信号機ボタンの並ぶ上端はタイトルバーとして振る舞わせる
          // (ドラッグで移動、ダブルクリックで拡大 / 元に戻す)。
          const WindowDragArea(child: SizedBox(height: 52)),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 0, 2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.l10n.sidebarTitle,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          SidebarItem(
            label: context.l10n.navLearning,
            count: '$learningCount',
            selected: view == MainView.learning,
            onTap: () => ref
                .read(mainPageProvider.notifier)
                .selectView(MainView.learning),
          ),
          SidebarItem(
            label: context.l10n.navAllWords,
            count: '$wordCount',
            selected: view == MainView.allWords,
            onTap: () => ref
                .read(mainPageProvider.notifier)
                .selectView(MainView.allWords),
          ),
          SidebarItem(
            label: context.l10n.navQuiz,
            count: '$learnedCount',
            selected: view == MainView.quiz,
            // クリックで常に新セッションを開始してからビューへ切り替える。
            onTap: () {
              ref.read(quizPageProvider.notifier).startQuiz();
              ref.read(mainPageProvider.notifier).selectView(MainView.quiz);
            },
          ),
          SidebarItem(
            label: context.l10n.navRegistration,
            selected: view == MainView.registration,
            onTap: () => ref
                .read(mainPageProvider.notifier)
                .selectView(MainView.registration),
          ),
          const Spacer(),
          SidebarItem(
            label: context.l10n.navSettings,
            selected: view == MainView.settings,
            onTap: () => ref
                .read(mainPageProvider.notifier)
                .selectView(MainView.settings),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x0F000000))),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.l10n.sidebarSavedLocally,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0x59000000),
                    ),
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
