import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:eitangocho/features/settings/domain/word_sort_order.dart';
import 'package:eitangocho/features/word/data/word_list_provider.dart';
import 'package:eitangocho/features/word/presentation/widgets/edit_word_dialog.dart';
import 'package:eitangocho/features/word/presentation/widgets/word_context_menu.dart';
import 'package:eitangocho/features/word/presentation/widgets/word_table_header.dart';
import 'package:eitangocho/features/word/presentation/widgets/word_table_row.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 全単語テーブル(検索・学習済みトグル)。
class AllWordsView extends ConsumerWidget {
  const AllWordsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = ref.watch(filteredWordListProvider);
    final sortGroup =
        (ref.watch(settingsProvider).value?.wordSortOrder ??
                const SettingsState().wordSortOrder)
            .group;

    // ビューが最小テーブル幅より狭いときは横スクロールにする
    // (プロトタイプの min-width + overflow:auto 準拠。UI スケールを上げた
    // 状態でウィンドウを狭めても列がはみ出してレンダリングエラーにならない)。
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth < AppDimensions.tableMinWidth
            ? AppDimensions.tableMinWidth
            : constraints.maxWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Column(
              children: [
                const WordTableHeader(),
                Expanded(
                  child: ListView.builder(
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final word = words[index];
                      return WordTableRow(
                        word: word,
                        onToggleLearned: (isLearned) => ref
                            .read(databaseProvider)
                            .wordDao
                            .setLearned(word.id, isLearned: isLearned),
                        onTap: () => showEditWordDialog(context, ref, word),
                        showCorrectCount:
                            sortGroup == WordSortGroup.correctCount,
                        onContextMenu: (position) =>
                            showWordContextMenu(context, ref, word, position),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
