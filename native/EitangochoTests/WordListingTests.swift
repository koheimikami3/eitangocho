import EitangochoData
import Foundation
import Testing

@testable import Eitangocho

/// Flutter 版の test/features/word/data/learning_words_provider_test.dart と
/// word_list_provider_test.dart を移したもの。
struct WordListingTests {
  private static func word(
    _ id: Int64, _ word: String, meaning: String? = nil, createdAt: Date, isLearned: Bool = false,
    correctCount: Int = 0
  ) -> Word {
    Word(
      id: id, word: word, meaning: meaning ?? "\(word) の訳", isLearned: isLearned, correctCount: correctCount,
      createdAt: createdAt, updatedAt: createdAt)
  }

  private static func date(_ year: Int, _ month: Int = 1) -> Date {
    Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month))!
  }

  // MARK: - 学習中

  private let learningWords = [
    word(3, "apple", meaning: "りんご", createdAt: date(2026)),
    word(2, "Banana", meaning: "バナナ", createdAt: date(2026)),
    word(1, "orange", meaning: "オレンジ", createdAt: date(2026), isLearned: true),
  ]

  @Test func 学習済みを除いた一覧を返す() {
    #expect(WordListing.filteredLearning(learningWords, query: "").map(\.word) == ["apple", "Banana"])
  }

  @Test func 検索は英単語が大文字小文字を無視した部分一致で訳には一致しない() {
    #expect(WordListing.filteredLearning(learningWords, query: "ban").map(\.word) == ["Banana"])
    #expect(WordListing.filteredLearning(learningWords, query: "りんご").isEmpty)
  }

  @Test func 検索語が学習済みの単語に一致しても出さない() {
    #expect(WordListing.filteredLearning(learningWords, query: "orange").isEmpty)
  }

  // MARK: - 全単語

  // 元の並び(WordDao.observeAll と同じ登録日の新しい順)。
  // cherry と Apple は同時刻に登録した想定で、id の大きい cherry が先。
  private let words = [
    word(4, "banana", createdAt: date(2026, 3), correctCount: 1),
    word(3, "cherry", createdAt: date(2026, 2), isLearned: true, correctCount: 3),
    word(2, "Apple", createdAt: date(2026, 2), correctCount: 1),
    word(1, "date", createdAt: date(2026), isLearned: true),
  ]

  private func sorted(_ order: WordSortOrder) -> [String] {
    WordListing.filteredAll(words, query: "", order: order).map(\.word)
  }

  @Test func 既定は登録日の新しい順で同時刻はidの新しい順() {
    #expect(sorted(.newest) == ["banana", "cherry", "Apple", "date"])
  }

  @Test func 登録日が古い順は新しい順のちょうど逆になる() {
    #expect(sorted(.oldest) == ["date", "Apple", "cherry", "banana"])
  }

  @Test func アルファベット順は大文字小文字を区別しない() {
    #expect(sorted(.alphabetical) == ["Apple", "banana", "cherry", "date"])
    #expect(sorted(.reverseAlphabetical) == ["date", "cherry", "banana", "Apple"])
  }

  @Test func 学習状態で並べ同じ状態の中は登録日の新しい順() {
    #expect(sorted(.learningFirst) == ["banana", "Apple", "cherry", "date"])
    #expect(sorted(.learnedFirst) == ["cherry", "date", "banana", "Apple"])
  }

  @Test func 覚えた回数で並べ同じ回数の中は登録日の新しい順() {
    #expect(sorted(.mostCorrect) == ["cherry", "banana", "Apple", "date"])
    #expect(sorted(.leastCorrect) == ["date", "banana", "Apple", "cherry"])
  }

  @Test func 検索で絞った結果も設定の並び順で返す() {
    // "a" は banana / Apple / date に一致する(英単語は大文字小文字を無視)。
    #expect(WordListing.filteredAll(words, query: "a", order: .alphabetical).map(\.word) == ["Apple", "banana", "date"])
  }

  @Test func 全単語の検索も訳には一致しない() {
    // 訳はすべて「<単語> の訳」なので、訳も対象なら全件が一致してしまう。
    #expect(WordListing.filteredAll(words, query: "訳", order: .newest).isEmpty)
  }
}
