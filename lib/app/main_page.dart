import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/app/widgets/app_sidebar.dart';
import 'package:eitangocho/app/widgets/main_toolbar.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_view.dart';
import 'package:eitangocho/features/word/presentation/all_words_view.dart';
import 'package:eitangocho/features/word/presentation/learning_words_view.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アプリシェル: サイドバー + ツールバー + コンテンツ切替。
class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    // 設定ビューは C3 で実装する。
                    MainView.settings => const Center(child: Text('未実装')),
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
