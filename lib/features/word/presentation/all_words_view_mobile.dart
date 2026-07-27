import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:eitangocho/features/word/data/word_list_provider.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_word_row.dart';
import 'package:eitangocho/features/word/presentation/widgets/word_edit_sheet.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版の全単語リスト。macOS 版のテーブルに代わる 1 行 1 単語のリスト。
class AllWordsViewMobile extends ConsumerWidget {
  const AllWordsViewMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final words = ref.watch(filteredWordListProvider);
    // macOS 版のテーブルは showIpa を無視して常時表示だが、iOS は幅が厳しく
    // IPA の有無で行の見え方が変わるため、設定に従わせる。
    final showIpa =
        ref.watch(settingsProvider).value?.showIpa ??
        const SettingsState().showIpa;

    if (words.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            '単語がまだありません。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: palette.textAlpha(45)),
          ),
        ),
      );
    }

    return ListView.builder(
      // タブバーが重なる分の余白(シェルが MediaQuery で渡している)。
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        return MobileWordRow(
          word: word,
          showIpa: showIpa,
          onToggleLearned: (isLearned) => ref
              .read(databaseProvider)
              .wordDao
              .setLearned(word.id, isLearned: isLearned),
          onTap: () => showWordEditSheet(context, ref, word),
        );
      },
    );
  }
}
