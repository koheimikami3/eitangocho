import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/app/widgets/toolbar_search_field.dart';
import 'package:eitangocho/app/widgets/window_drag_area.dart';
import 'package:eitangocho/components/app_filled_button.dart';
import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/features/word/presentation/widgets/word_sort_button.dart';
import 'package:eitangocho/utils/l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アプリシェルのツールバー。ビュータイトル・検索・登録ボタンを表示する。
class MainToolbar extends ConsumerWidget {
  const MainToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(mainPageProvider.select((s) => s.view));
    final title = switch (view) {
      MainView.learning => context.l10n.navLearningWords,
      MainView.allWords => context.l10n.navAllWords,
      MainView.quiz => context.l10n.navQuiz,
      MainView.registration => context.l10n.navRegistration,
      MainView.settings => context.l10n.navSettings,
    };
    // 検索は学習中・全単語ビューのみ表示(プロトタイプの showSearch 準拠)。
    final showSearch = view == MainView.learning || view == MainView.allWords;

    return Container(
      height: AppDimensions.toolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // iOS のヘッダと同じく白地にし、下のグレーの地(カードを並べる面)と
      // 分ける(2.2.0)。
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      // タイトルバーの代わり: 空いている所のドラッグで移動、ダブルクリックで
      // 拡大 / 元に戻す。ボタン・検索欄はその上に重なるので影響しない。
      child: Stack(
        // Row に従来どおりツールバーの高さいっぱいを渡し、縦中央に揃える。
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: WindowDragArea()),
          Row(
            children: [
              // タイトルの上でもドラッグ・ダブルクリックが効くよう、
              // 当たり判定を後ろの WindowDragArea に通す。
              IgnorePointer(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // 並び替えは全単語だけ(学習中は登録順のカード表示のまま)。
              // Spacer の代わりに余白ごと受け持ち、右寄せで置く。既定の uiScale で
              // ウィンドウを最小幅まで狭めると収まらないため、そのときは
              // WordSortButton が並び順の文字を省略して縮む。
              if (view == MainView.allWords)
                const Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, right: 10),
                      child: WordSortButton(),
                    ),
                  ),
                )
              else
                const Spacer(),
              if (showSearch) ...[
                const ToolbarSearchField(),
                const SizedBox(width: 10),
              ],
              AppFilledButton(
                label: context.l10n.addWord,
                verticalPadding: 6,
                fontSize: 13,
                borderRadius: 7,
                onPressed: () => ref
                    .read(mainPageProvider.notifier)
                    .selectView(MainView.registration),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
