import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/app/shells/widgets/mobile_search_field.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/word/data/learning_words_provider.dart';
import 'package:eitangocho/features/word/data/word_list_provider.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版のヘッダ。ビュー名・件数・「＋ 登録」ボタン・検索欄。
///
/// 検索欄と登録ボタンは学習中 / 全単語のときだけ出す(デザインの
/// showSearch / showAdd に対応)。
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
        border: Border(
          bottom: BorderSide(color: palette.borderAlpha(8)),
        ),
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
                              _titleOf(view),
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
                              _countOf(ref, view),
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
              if (showSearchAndAdd)
                const Padding(
                  padding: EdgeInsets.only(top: 4, bottom: 10),
                  child: MobileSearchField(),
                )
              else
                const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _titleOf(MainView view) => switch (view) {
    MainView.learning => '学習中',
    MainView.allWords => '全単語',
    MainView.quiz => 'フラッシュクイズ',
    MainView.registration => '単語を登録',
    MainView.settings => '設定',
  };

  /// 件数はタイトルの脇に小さく出す(学習中 / 全単語のみ)。
  String _countOf(WidgetRef ref, MainView view) => switch (view) {
    MainView.learning => '${ref.watch(learningWordsProvider).length}語',
    MainView.allWords =>
      '${ref.watch(wordListProvider).value?.length ?? 0}語',
    _ => '',
  };
}

class _AddWordButton extends StatelessWidget {
  const _AddWordButton();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      // 登録はタブではなくシートで開く(デザインどおり)。
      onTap: () => showWordRegistrationSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: palette.accent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '＋ 登録',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
