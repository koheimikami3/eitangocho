import 'package:eitangocho/l10n/app_localizations.dart';

/// 全単語一覧の並び順。学習中一覧・クイズ・エクスポートの並びには影響しない。
///
/// 「基準 + 昇順/降順」に分けず 8 通りを平らに持つのは、学習状態のように
/// 昇順・降順では意味が伝わらない基準があり、メニューでも 1 タップで
/// 選ばせたいため。メニューの区切りは [group] で判定する。
enum WordSortOrder {
  newest(WordSortGroup.createdAt),
  oldest(WordSortGroup.createdAt),
  alphabetical(WordSortGroup.alphabet),
  reverseAlphabetical(WordSortGroup.alphabet),
  learningFirst(WordSortGroup.learned),
  learnedFirst(WordSortGroup.learned),
  mostCorrect(WordSortGroup.correctCount),
  leastCorrect(WordSortGroup.correctCount);

  const WordSortOrder(this.group);

  /// メニューの表示用ラベル
  String label(AppLocalizations l10n) => switch (this) {
    newest => l10n.sortNewest,
    oldest => l10n.sortOldest,
    // アルファベット順はどの言語でも同じ表記なので訳さない
    alphabetical => 'A → Z',
    reverseAlphabetical => 'Z → A',
    learningFirst => l10n.sortLearningFirst,
    learnedFirst => l10n.sortLearnedFirst,
    mostCorrect => l10n.sortMostCorrect,
    leastCorrect => l10n.sortLeastCorrect,
  };

  /// 並べる基準。メニューで基準ごとに区切り線を入れるために使う。
  final WordSortGroup group;
}

/// [WordSortOrder] の基準。
enum WordSortGroup { createdAt, alphabet, learned, correctCount }
