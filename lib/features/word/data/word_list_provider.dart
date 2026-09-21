import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:eitangocho/features/settings/domain/word_sort_order.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 単語一覧・検索フィルタ後の一覧。drift の生成型(Word)を戻り値にするため、
/// riverpod_generator と drift の既知の非互換(riverpod #4370 / #4323: 他の
/// generator が生成した型を @riverpod の戻り値にすると InvalidTypeException で
/// コード生成が失敗する)を避けて手書きの Provider として定義する。
final wordListProvider = StreamProvider<List<Word>>(
  (ref) => ref.watch(databaseProvider).wordDao.watchAll(),
);

/// ツールバー検索でフィルタし、設定の並び順([WordSortOrder])で並べた一覧
/// (全単語ビュー用)。
/// 英単語は大文字小文字を無視した部分一致、日本語訳はそのまま部分一致(プロトタイプ準拠)。
///
/// 並び替えは DB クエリではなくここで行う。wordListProvider は学習中一覧や
/// 件数表示とも共有しており、クエリ側で並べると全単語以外にも波及するため。
final filteredWordListProvider = Provider<List<Word>>((ref) {
  final words = ref.watch(wordListProvider).value ?? const <Word>[];
  final query = ref.watch(mainPageProvider.select((s) => s.searchQuery)).trim();
  final order = ref.watch(
    settingsProvider.select(
      (s) => s.value?.wordSortOrder ?? const SettingsState().wordSortOrder,
    ),
  );
  final lower = query.toLowerCase();
  final filtered = query.isEmpty
      ? [...words]
      : words
            .where(
              (w) =>
                  w.word.toLowerCase().contains(lower) ||
                  w.japanese.contains(query),
            )
            .toList();
  return filtered..sort((a, b) => _compareWords(a, b, order));
});

/// [order] での比較。同じ順位なら登録日の新しい順(WordDao.watchAll と同じ)で決める。
/// List.sort は安定ソートではないため、元の並びに頼らず比較関数で順位を確定させる。
int _compareWords(Word a, Word b, WordSortOrder order) {
  final primary = switch (order) {
    WordSortOrder.newest => 0,
    WordSortOrder.oldest => -_compareNewest(a, b),
    // 大文字小文字は区別しない(登録時の重複判定 WordDao._matchKey と揃える)。
    WordSortOrder.alphabetical => a.word.toLowerCase().compareTo(
      b.word.toLowerCase(),
    ),
    WordSortOrder.reverseAlphabetical => b.word.toLowerCase().compareTo(
      a.word.toLowerCase(),
    ),
    WordSortOrder.learningFirst => _learnedRank(a) - _learnedRank(b),
    WordSortOrder.learnedFirst => _learnedRank(b) - _learnedRank(a),
    WordSortOrder.mostCorrect => b.correctCount - a.correctCount,
    WordSortOrder.leastCorrect => a.correctCount - b.correctCount,
  };
  return primary != 0 ? primary : _compareNewest(a, b);
}

/// 登録日の新しい順(同時刻は id の新しい順)。
int _compareNewest(Word a, Word b) {
  final byCreatedAt = b.createdAt.compareTo(a.createdAt);
  return byCreatedAt != 0 ? byCreatedAt : b.id - a.id;
}

int _learnedRank(Word w) => w.isLearned ? 1 : 0;
