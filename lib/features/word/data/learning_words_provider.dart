import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/data/word_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 学習中(未学習)の単語一覧。wordListProvider から派生し、DB へ追加クエリは投げない。
/// drift 生成型(Word)を戻り値にするため、riverpod_generator との既知の非互換を避けて
/// 手書きの Provider として定義する(word_list_provider.dart と同じ理由)。
final learningWordsProvider = Provider<List<Word>>((ref) {
  final words = ref.watch(wordListProvider).value ?? const <Word>[];
  return words.where((w) => !w.isLearned).toList();
});

/// 学習済みの単語一覧(クイズの出題対象・サイドバー件数用)。
final learnedWordsProvider = Provider<List<Word>>((ref) {
  final words = ref.watch(wordListProvider).value ?? const <Word>[];
  return words.where((w) => w.isLearned).toList();
});

/// ツールバー検索でフィルタした学習中一覧(学習中カードビュー用)。
/// 検索ロジックは filteredWordListProvider と同一(英=大文字小文字無視の部分一致、日=部分一致)。
///
/// learningWordsProvider ではなく wordListProvider から直接算出する。派生を
/// 2 段に重ねると、チェーン全体がリスナー 0 の間(iOS で学習中タブを離れている間)
/// に元データが更新されたとき、次にビューが build する瞬間に riverpod が
/// 祖先の再計算 → 子の無効化を同期的に行い、「build 中の setState」で例外になる。
final filteredLearningWordsProvider = Provider<List<Word>>((ref) {
  final words = ref.watch(wordListProvider).value ?? const <Word>[];
  final query = ref.watch(mainPageProvider.select((s) => s.searchQuery)).trim();
  final lower = query.toLowerCase();
  return words
      .where(
        (w) =>
            !w.isLearned &&
            (query.isEmpty ||
                w.word.toLowerCase().contains(lower) ||
                w.meaning.contains(query)),
      )
      .toList();
});
