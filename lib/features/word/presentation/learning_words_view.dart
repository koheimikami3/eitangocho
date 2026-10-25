import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:eitangocho/features/word/data/learning_words_provider.dart';
import 'package:eitangocho/features/word/data/word_list_provider.dart';
import 'package:eitangocho/features/word/presentation/widgets/card_in.dart';
import 'package:eitangocho/features/word/presentation/widgets/edit_word_dialog.dart';
import 'package:eitangocho/features/word/presentation/widgets/learning_empty_state.dart';
import 'package:eitangocho/features/word/presentation/widgets/word_card.dart';
import 'package:eitangocho/features/word/presentation/widgets/word_context_menu.dart';
import 'package:eitangocho/features/word/presentation/word_learned_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 学習中(未学習)単語のカードグリッドビュー。
class LearningWordsView extends ConsumerWidget {
  const LearningWordsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final words = ref.watch(filteredLearningWordsProvider);
    // 設定 showIpa はカードの IPA 表示のみに適用する(テーブルは常時表示)。
    // ロード前は既定 true。
    final showIpa =
        ref.watch(settingsProvider).value?.showIpa ??
        const SettingsState().showIpa;

    if (ref.watch(wordListLoadingProvider)) {
      return Center(child: CircularProgressIndicator(color: colors.accent));
    }
    if (words.isEmpty) return const LearningEmptyState();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.contentPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)) 相当。
          // 横幅に収まる最大列数を求め、gridGap で等分する。
          const minWidth = AppDimensions.cardMinWidth;
          const gap = AppDimensions.gridGap;
          final maxColumns = ((constraints.maxWidth + gap) / (minWidth + gap))
              .floor();
          final columns = maxColumns < 1 ? 1 : maxColumns;
          final cardWidth =
              (constraints.maxWidth - gap * (columns - 1)) / columns;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final word in words)
                // ValueKey(word.id) により、検索フィルタや削除での再構築では
                // 既存カードの State が保持され再アニメーションしない
                // (新規カードとビュー再入場時のみ cardIn が再生される)。
                KeyedSubtree(
                  key: ValueKey(word.id),
                  child: SizedBox(
                    width: cardWidth,
                    child: CardIn(
                      child: WordCard(
                        word: word,
                        showIpa: showIpa,
                        onToggleLearned: (isLearned) =>
                            toggleWordLearned(ref, word, isLearned: isLearned),
                        onTap: () => showEditWordDialog(context, ref, word),
                        onContextMenu: (position) =>
                            showWordContextMenu(context, ref, word, position),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
