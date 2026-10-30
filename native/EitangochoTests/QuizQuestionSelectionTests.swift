import EitangochoData
import Foundation
import Testing

@testable import Eitangocho

/// Flutter 版の quiz_question_selection_test.dart を移したもの。
struct QuizQuestionSelectionTests {
  private static let base = Date(timeIntervalSince1970: 1_790_000_000)

  /// `answeredDaysAgo` が nil なら未出題(lastReviewedAt が nil)。
  private func word(_ id: Int64, answeredDaysAgo: Int? = nil) -> Word {
    Word(
      id: id, word: "word\(id)", meaning: "訳\(id)", isLearned: true,
      lastReviewedAt: answeredDaysAgo.map { Self.base.addingTimeInterval(-Double($0) * 86_400) },
      createdAt: Self.base, updatedAt: Self.base)
  }

  private func ids(_ words: [Word]) -> Set<Int64> { Set(words.map(\.id)) }

  @Test func 出題数以下なら全部出す() {
    let learned = (0..<3).map { word(Int64($0), answeredDaysAgo: $0) }
    #expect(ids(selectQuizQuestions(learned)) == [0, 1, 2])
  }

  @Test func 出題数を超える分は出さず重複もしない() {
    let learned = (0..<25).map { word(Int64($0), answeredDaysAgo: $0) }
    let questions = selectQuizQuestions(learned)
    #expect(questions.count == quizQuestionCount)
    #expect(ids(questions).count == quizQuestionCount)
  }

  @Test func 答えた単語は最後に答えた日時の古い順に選ぶ() {
    // id が大きいほど古い。古い 10 語(id 5〜14)が選ばれる。
    let learned = (0..<15).map { word(Int64($0), answeredDaysAgo: $0) }
    #expect(ids(selectQuizQuestions(learned)) == Set(5..<15))
  }

  @Test func まだ答えていない単語を答えた単語より先に選ぶ() {
    let learned = (0..<12).map { word(Int64($0), answeredDaysAgo: 100 + $0) } + [word(100), word(101)]
    // 未出題 2 語 + 答えた中で古い 8 語(id 4〜11)。
    #expect(ids(selectQuizQuestions(learned)) == Set([100, 101] + Array(4..<12)))
  }
}
