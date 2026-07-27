import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/app/shells/widgets/mobile_header.dart';
import 'package:eitangocho/app/shells/widgets/mobile_tab_bar.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_view.dart';
import 'package:eitangocho/features/settings/presentation/settings_view.dart';
import 'package:eitangocho/features/word/presentation/all_words_view.dart';
import 'package:eitangocho/features/word/presentation/learning_words_view.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版のシェル: ヘッダ + コンテンツ + 下タブバー。
///
/// タブは 4 つ(学習中 / 全単語 / クイズ / 設定)で、単語登録はタブに置かず
/// ヘッダの「＋ 登録」から開く。[MainView.registration] のときはどのタブも
/// 選択状態にならない。
class TabBarShell extends ConsumerWidget {
  const TabBarShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: Center(
        // iPad でも iPhone 相当の幅に収める(iPad 専用レイアウトを作るまでの措置)。
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.mobileContentMaxWidth,
          ),
          child: const _ShellBody(),
        ),
      ),
    );
  }
}

class _ShellBody extends ConsumerWidget {
  const _ShellBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(mainPageProvider.select((s) => s.view));

    // タブバーは半透明でコンテンツの上に重なる(デザインの position:absolute +
    // backdrop-filter)。そのため Column ではなく Stack で重ね、コンテンツ側は
    // タブバーの高さ分だけ下に余白を取る。
    return Stack(
      children: [
        Column(
          children: [
            const MobileHeader(),
            Expanded(
              // 上のセーフエリアはヘッダが消費済み。下端はタブバーが重なるので、
              // その分をビュー側のスクロール余白として渡す。
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: EdgeInsets.only(
                    bottom: MobileTabBar.heightOf(context),
                  ),
                ),
                child: switch (view) {
                  MainView.learning => const LearningWordsView(),
                  MainView.allWords => const AllWordsView(),
                  MainView.quiz => const QuizView(),
                  MainView.registration => const WordRegistrationView(),
                  MainView.settings => const SettingsView(),
                },
              ),
            ),
          ],
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: MobileTabBar(),
        ),
      ],
    );
  }
}
