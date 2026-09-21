/// 全単語一覧の並び順。学習中一覧・クイズ・エクスポートの並びには影響しない。
///
/// 「基準 + 昇順/降順」に分けず 8 通りを平らに持つのは、学習状態のように
/// 昇順・降順では意味が伝わらない基準があり、メニューでも 1 タップで
/// 選ばせたいため。メニューの区切りは [group] で判定する。
enum WordSortOrder {
  newest('登録日が新しい順', WordSortGroup.createdAt),
  oldest('登録日が古い順', WordSortGroup.createdAt),
  alphabetical('A → Z', WordSortGroup.alphabet),
  reverseAlphabetical('Z → A', WordSortGroup.alphabet),
  learningFirst('学習中 → 学習済み', WordSortGroup.learned),
  learnedFirst('学習済み → 学習中', WordSortGroup.learned),
  mostCorrect('覚えた回数が多い順', WordSortGroup.correctCount),
  leastCorrect('覚えた回数が少ない順', WordSortGroup.correctCount);

  const WordSortOrder(this.label, this.group);

  /// メニューの表示用ラベル
  final String label;

  /// 並べる基準。メニューで基準ごとに区切り線を入れるために使う。
  final WordSortGroup group;
}

/// [WordSortOrder] の基準。
enum WordSortGroup { createdAt, alphabet, learned, correctCount }
