import 'package:eitangocho/db/app_database.dart';

/// 1 セッションの出題数。
///
/// 回答ごとに lastReviewedAt を記録するので、全単語を回す仕組みは区切りの長さに
/// 依存しない。区切りは結果画面(忘れた単語の見返し・広告・レビュー依頼)に
/// 届くためのもので、短い方が手軽に終えられ、結果画面にも届きやすい。
const quizQuestionCount = 10;

/// 学習済み単語から 1 セッション分の出題を選ぶ。
///
/// 1. まだ一度も答えていない単語(lastReviewedAt が null)をランダムに先に出す。
///    覚えた後、まだ一度も想起を確かめていないため
/// 2. 残りは lastReviewedAt の古い順。全単語を等間隔で一巡させる
///    (単語ごとに間隔を延ばす方式が等間隔より優れるとは言えないため採らない)
/// 3. 選んだ分は出題順をシャッフルする
///
/// 途中でやめても、答えていない単語は日時が古いまま残るので次回の先頭に来る
/// (続きの位置を別に覚えておく必要がない)。
List<Word> selectQuizQuestions(List<Word> learned) {
  final unanswered = [
    for (final w in learned)
      if (w.lastReviewedAt == null) w,
  ]..shuffle();
  final answered = [
    for (final w in learned)
      if (w.lastReviewedAt != null) w,
  ]..sort((a, b) => a.lastReviewedAt!.compareTo(b.lastReviewedAt!));
  return [...unanswered, ...answered].take(quizQuestionCount).toList()
    ..shuffle();
}
