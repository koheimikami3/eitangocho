import EitangochoData

/// 1 セッションの出題数。
///
/// 回答ごとに lastReviewedAt を記録するので、全単語を回す仕組みは区切りの長さに
/// 依存しない。区切りは結果画面(忘れた単語の見返し・レビュー依頼)に
/// 届くためのもので、短い方が手軽に終えられ、結果画面にも届きやすい。
let quizQuestionCount = 10

/// 学習済み単語から 1 セッション分の出題を選ぶ(Flutter 版の selectQuizQuestions)。
///
/// 1. まだ一度も答えていない単語(lastReviewedAt が nil)をランダムに先に出す。
///    覚えた後、まだ一度も想起を確かめていないため
/// 2. 残りは lastReviewedAt の古い順。全単語を等間隔で一巡させる
///    (単語ごとに間隔を延ばす方式が等間隔より優れるとは言えないため採らない)
/// 3. 選んだ分は出題順をシャッフルする
///
/// 途中でやめても、答えていない単語は日時が古いまま残るので次回の先頭に来る
/// (続きの位置を別に覚えておく必要がない)。
func selectQuizQuestions(_ learned: [Word]) -> [Word] {
  let unanswered = learned.filter { $0.lastReviewedAt == nil }.shuffled()
  let answered = learned.compactMap { word in word.lastReviewedAt.map { (word, $0) } }
    .sorted { $0.1 < $1.1 }
    .map(\.0)
  return Array((unanswered + answered).prefix(quizQuestionCount)).shuffled()
}
