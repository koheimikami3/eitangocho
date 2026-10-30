import EitangochoData

/// 一覧の絞り込みと並べ替え(Flutter 版の learning_words_provider / word_list_provider)。
///
/// 元の一覧は WordDao.observeAll の並び(登録日の新しい順、同時刻は id の新しい順)。
/// 検索は英単語だけを対象に、大文字小文字を無視した部分一致で絞る。訳は対象にしない。
/// 検索欄からは英単語の検索にしか見えず、訳で一致することが利用者に伝わらないうえ、
/// 訳がラテン文字の言語(西・仏)では英単語の検索に訳の一致が混ざるため。
enum WordListing {
  /// 学習中(未学習)の単語。
  static func learning(_ words: [Word]) -> [Word] {
    words.filter { !$0.isLearned }
  }

  /// 学習済みの単語(クイズの出題対象)。
  static func learned(_ words: [Word]) -> [Word] {
    words.filter(\.isLearned)
  }

  /// 検索で絞った学習中の一覧(学習中のカードの画面)。
  static func filteredLearning(_ words: [Word], query: String) -> [Word] {
    filter(words, query: query).filter { !$0.isLearned }
  }

  /// 検索で絞り、設定の並び順で並べた一覧(全単語の画面)。
  ///
  /// 並べ替えは DB のクエリではなくここで行う。元の一覧は学習中の一覧や
  /// 件数の表示とも共有しており、クエリ側で並べると全単語以外にも波及するため。
  static func filteredAll(_ words: [Word], query: String, order: WordSortOrder) -> [Word] {
    filter(words, query: query).sorted { compare($0, $1, order) < 0 }
  }

  private static func filter(_ words: [Word], query: String) -> [Word] {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return words }
    let lower = trimmed.lowercased()
    return words.filter { $0.word.lowercased().contains(lower) }
  }

  /// `order` での比較。同じ順位なら登録日の新しい順で決める
  /// (並べ替えの安定性に頼らず、比較関数で順位を確定させる)。
  private static func compare(_ a: Word, _ b: Word, _ order: WordSortOrder) -> Int {
    let primary: Int
    switch order {
    case .newest: primary = 0
    case .oldest: primary = -compareNewest(a, b)
    // 大文字小文字は区別しない(登録時の重複判定 WordDao.matchKey と揃える)。
    case .alphabetical: primary = compareStrings(a.word.lowercased(), b.word.lowercased())
    case .reverseAlphabetical: primary = compareStrings(b.word.lowercased(), a.word.lowercased())
    case .learningFirst: primary = learnedRank(a) - learnedRank(b)
    case .learnedFirst: primary = learnedRank(b) - learnedRank(a)
    case .mostCorrect: primary = b.correctCount - a.correctCount
    case .leastCorrect: primary = a.correctCount - b.correctCount
    }
    return primary != 0 ? primary : compareNewest(a, b)
  }

  /// 登録日の新しい順(同時刻は id の新しい順)。
  private static func compareNewest(_ a: Word, _ b: Word) -> Int {
    if a.createdAt != b.createdAt { return a.createdAt > b.createdAt ? -1 : 1 }
    return a.id == b.id ? 0 : (a.id > b.id ? -1 : 1)
  }

  private static func compareStrings(_ a: String, _ b: String) -> Int {
    a == b ? 0 : (a < b ? -1 : 1)
  }

  private static func learnedRank(_ word: Word) -> Int { word.isLearned ? 1 : 0 }
}
