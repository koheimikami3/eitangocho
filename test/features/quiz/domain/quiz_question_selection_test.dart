import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/quiz/domain/quiz_question_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final base = DateTime(2026, 10, 1);

  /// [answeredDaysAgo] が null なら未出題(lastReviewedAt が null)。
  Word word(int id, {int? answeredDaysAgo}) => Word(
    id: id,
    word: 'word$id',
    ipa: '',
    meaning: '訳$id',
    partsOfSpeech: const [],
    exampleEn: '',
    exampleTranslation: '',
    translationLanguage: 'ja',
    audioUrl: '',
    isLearned: true,
    lastReviewedAt: answeredDaysAgo == null
        ? null
        : base.subtract(Duration(days: answeredDaysAgo)),
    correctCount: 0,
    createdAt: base,
    updatedAt: base,
  );

  Set<int> idsOf(List<Word> words) => {for (final w in words) w.id};

  test('出題数以下なら全部出す', () {
    final learned = [for (var i = 0; i < 3; i++) word(i, answeredDaysAgo: i)];

    expect(idsOf(selectQuizQuestions(learned)), {0, 1, 2});
  });

  test('出題数を超える分は出さず、重複もしない', () {
    final learned = [for (var i = 0; i < 25; i++) word(i, answeredDaysAgo: i)];

    final questions = selectQuizQuestions(learned);

    expect(questions, hasLength(quizQuestionCount));
    expect(idsOf(questions), hasLength(quizQuestionCount));
  });

  test('答えた単語は最後に答えた日時の古い順に選ぶ', () {
    // id が大きいほど古い。古い 10 語(id 5〜14)が選ばれる。
    final learned = [for (var i = 0; i < 15; i++) word(i, answeredDaysAgo: i)];

    expect(idsOf(selectQuizQuestions(learned)), {
      for (var i = 5; i < 15; i++) i,
    });
  });

  test('まだ答えていない単語を、答えた単語より先に選ぶ', () {
    final learned = [
      for (var i = 0; i < 12; i++) word(i, answeredDaysAgo: 100 + i),
      word(100),
      word(101),
    ];

    // 未出題 2 語 + 答えた中で古い 8 語(id 4〜11)。
    expect(idsOf(selectQuizQuestions(learned)), {
      100,
      101,
      for (var i = 4; i < 12; i++) i,
    });
  });
}
