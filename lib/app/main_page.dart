import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/app/widgets/app_sidebar.dart';
import 'package:eitangocho/app/widgets/main_toolbar.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_view.dart';
import 'package:eitangocho/features/settings/presentation/settings_view.dart';
import 'package:eitangocho/features/word/presentation/all_words_view.dart';
import 'package:eitangocho/features/word/presentation/learning_words_view.dart';
import 'package:eitangocho/features/word_registration/data/ejdict_importer.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アプリシェル: サイドバー + ツールバー + コンテンツ切替。
class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // EJDict の初回取込をバックグラウンドでキックする(UI はブロックしない。
    // 自動入力側が完了を await するため、起動直後から開始しておく)。
    ref.watch(ejdictImportProvider);
    final view = ref.watch(mainPageProvider.select((s) => s.view));

    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(),
          Expanded(
            child: Column(
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
    );
  }
}
