import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/app/widgets/app_menu_bar.dart';
import 'package:eitangocho/app/widgets/app_sidebar.dart';
import 'package:eitangocho/app/widgets/main_toolbar.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_view.dart';
import 'package:eitangocho/features/settings/presentation/settings_view.dart';
import 'package:eitangocho/features/word/presentation/all_words_view.dart';
import 'package:eitangocho/features/word/presentation/learning_words_view.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// macOS 版のシェル: サイドバー + ツールバー + コンテンツ切替。
class SidebarShell extends ConsumerWidget {
  const SidebarShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(mainPageProvider.select((s) => s.view));

    // ⌘N/⌘F は macOS のネイティブメニューバー(AppMenuBar)経由で処理する。
    // Command 系は focus ベースの CallbackShortcuts には届かないため。
    return AppMenuBar(
      child: Scaffold(
        body: Row(
          children: [
            const AppSidebar(),
            Expanded(
              child: Column(
                // 各ビューをコンテンツ幅に関わらず全幅に広げる(既定の center だと
                // カードが少ないときなどにコンテンツごと中央寄せになってしまう)。
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const MainToolbar(),
                  Expanded(
                    child: switch (view) {
                      MainView.learning => const LearningWordsView(),
                      MainView.allWords => const AllWordsView(),
                      MainView.quiz => const QuizView(),
                      MainView.registration => const WordRegistrationView(),
                      MainView.settings => const SettingsView(),
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
