import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:eitangocho/features/word/data/learning_words_provider.dart';
import 'package:eitangocho/features/word/presentation/widgets/card_in.dart';
import 'package:eitangocho/features/word/presentation/widgets/learning_empty_state.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_word_card.dart';
import 'package:eitangocho/features/word/presentation/widgets/word_edit_sheet.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS 版の学習中(未学習)単語カードビュー。2 列固定グリッド。
class LearningWordsViewMobile extends ConsumerWidget {
  const LearningWordsViewMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final words = ref.watch(filteredLearningWordsProvider);
    // 設定 showIpa はカードの IPA 表示のみに適用する(macOS 版と同じ)。
    final showIpa =
        ref.watch(settingsProvider).value?.showIpa ??
        const SettingsState().showIpa;

    if (words.isEmpty) return const LearningEmptyState();

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.mobilePadding,
        AppDimensions.mobilePadding,
        AppDimensions.mobilePadding,
        // タブバーが重なる分の余白(シェルが MediaQuery で渡している)。
        AppDimensions.mobilePadding + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'チェックを入れると学習済みになり、このリストから消えます。'
            'カードをタップすると編集できます。',
            style: TextStyle(
              fontSize: 12,
              height: 1.6,
              color: palette.textAlpha(45),
            ),
          ),
        ),
        // GridView は行の高さを揃えてしまい、内容量の少ないカードに合わせて
        // 背の高いカードが切れる。デザインの grid(align-items:start)に
        // 合わせ、macOS 版と同じく Wrap で高さを内容なりにする。
        LayoutBuilder(
          builder: (context, constraints) {
            const columns = AppDimensions.mobileCardColumns;
            const gap = AppDimensions.mobileGridGap;
            final cardWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final word in words)
                  // ValueKey により、検索フィルタや削除での再構築では既存カードの
                  // State(訳の表示状態)が保持され再アニメーションしない。
                  KeyedSubtree(
                    key: ValueKey(word.id),
                    child: SizedBox(
                      width: cardWidth,
                      child: CardIn(
                        child: MobileWordCard(
                          word: word,
                          showIpa: showIpa,
                          onToggleLearned: (isLearned) => ref
                              .read(databaseProvider)
                              .wordDao
                              .setLearned(word.id, isLearned: isLearned),
                          onTap: () => showWordEditSheet(context, ref, word),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
