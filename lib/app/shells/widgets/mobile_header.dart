import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/app/shells/widgets/mobile_search_field.dart';
import 'package:eitangocho/components/mobile_filled_button.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/word/data/learning_words_provider.dart';
import 'package:eitangocho/features/word/data/word_list_provider.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_word_sort_button.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_sheet.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版のヘッダ。ビュー名・件数・「＋ 登録」ボタン・検索欄。
///
/// 検索欄と登録ボタンは学習中 / 全単語のときだけ出す(デザインの
/// showSearch / showAdd に対応)。全単語のときだけ検索欄の下に並び替えの行を出す。
///
/// 下端は線ではなく影で区切る。影はコンテンツの上に落ちるため、シェル側で
/// ヘッダをコンテンツより後に描かせている(TabBarShell 参照)。
class MobileHeader extends ConsumerWidget {
  const MobileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final view = ref.watch(mainPageProvider.select((s) => s.view));
    final showSearchAndAdd =
        view == MainView.learning || view == MainView.allWords;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        boxShadow: palette.headerShadow,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.mobilePadding,
            6,
            AppDimensions.mobilePadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Row(
                  children: [
                    // タイトルと件数を 1 つの Expanded にまとめる。Flexible な
                    // タイトルと Spacer を並べると余った幅が両者に配分され、
                    // 登録ボタンが右端まで寄らない。
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              _titleOf(context, view),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: palette.text,
                              ),
                            ),
                          ),
                          if (showSearchAndAdd) ...[
                            const SizedBox(width: 8),
                            Text(
                              _countOf(context, ref, view),
                              style: TextStyle(
                                fontSize: 12,
                                color: palette.textAlpha(40),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (showSearchAndAdd) ...[
                      const SizedBox(width: 8),
                      const _AddWordButton(),
                    ],
                  ],
                ),
              ),
              if (showSearchAndAdd) ...[
                const Padding(
                  padding: EdgeInsets.only(top: 4, bottom: 10),
                  child: MobileSearchField(),
                ),
                // 並び替えは全単語だけ(学習中は登録順のカード表示のまま)。
                if (view == MainView.allWords)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: _SortRow(),
                  ),
              ] else
                const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _titleOf(BuildContext context, MainView view) => switch (view) {
    MainView.learning => context.l10n.navLearning,
    MainView.allWords => context.l10n.navAllWords,
    MainView.quiz => context.l10n.navQuiz,
    MainView.registration => context.l10n.navRegistration,
    MainView.settings => context.l10n.navSettings,
  };

  /// 件数はタイトルの脇に小さく出す(学習中 / 全単語のみ)。
  String _countOf(BuildContext context, WidgetRef ref, MainView view) =>
      switch (view) {
        MainView.learning => context.l10n.wordCount(
          ref.watch(learningWordsProvider).length,
        ),
        MainView.allWords => context.l10n.wordCount(
          ref.watch(wordListProvider).value?.length ?? 0,
        ),
        _ => '',
      };
}

class _AddWordButton extends StatelessWidget {
  const _AddWordButton();

  @override
  Widget build(BuildContext context) {
    return MobileFilledButton(
      label: context.l10n.addShort,
      // 登録はタブではなくシートで開く(デザインどおり)。
      onPressed: () => showWordRegistrationSheet(context),
      // 文字の大きさは 1.x と同じ 14px・太字(デザインの 13px・w600 は
      // 小さく見えたため採らない)。
      fontSize: 14,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      borderRadius: 8,
    );
  }
}

/// 全単語の並び替えの行。左に表示中の件数、右に現在の並び順のボタン。
class _SortRow extends ConsumerWidget {
  const _SortRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    return Row(
      children: [
        Expanded(
          child: Text(
            // 検索で絞り込んだ後の件数(タイトル脇の件数は全件)。
            context.l10n.showingWordCount(
              ref.watch(filteredWordListProvider).length,
            ),
            style: TextStyle(fontSize: 12, color: palette.textAlpha(45)),
          ),
        ),
        const SizedBox(width: 8),
        const MobileWordSortButton(),
      ],
    );
  }
}
