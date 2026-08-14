import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_notifier.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_state.dart';
import 'package:eitangocho/features/word/data/learning_words_provider.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../review/review_test_overrides.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // クイズを最後まで進めるとレビュー依頼の判定(回数の記録)を通る。
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  /// 学習済み単語を n 件投入し、learnedWordsProvider をその静的リストに
  /// 差し替えた container を返す。QuizPageNotifier は learnedWordsProvider しか
  /// 読まないため、drift の watch() ストリーム(wordListProvider)を購読させず、
  /// container 破棄時の購読解除タイマー衝突(drift #3323)を根本的に避ける。
  Future<ProviderContainer> setupLearned(int n) async {
    for (var i = 0; i < n; i++) {
      final id = await db.wordDao.insertWord(
        WordsCompanion(word: Value('word$i'), japanese: Value('訳$i')),
      );
      await db.wordDao.setLearned(id, isLearned: true);
    }
    final learned = (await db.wordDao.watchAll().first)
        .where((w) => w.isLearned)
        .toList();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        learnedWordsProvider.overrideWithValue(learned),
        reviewDisabled,
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('startQuiz は学習済み全件をシャッフルして出題する', () async {
    final container = await setupLearned(3);

    container.read(quizPageProvider.notifier).startQuiz();

    final state = container.read(quizPageProvider);
    expect(state.phase, QuizPhase.active);
    expect(state.questions, hasLength(3));
    expect(state.index, 0);
    expect(state.revealed, isFalse);
  });

  test('学習済みが 0 件だと phase が empty になる', () async {
    final container = await setupLearned(0);

    container.read(quizPageProvider.notifier).startQuiz();

    expect(container.read(quizPageProvider).phase, QuizPhase.empty);
  });

  test('answerKnew で index が進み okCount が加算され、最終問題で done になる', () async {
    final container = await setupLearned(2);
    final notifier = container.read(quizPageProvider.notifier);
    notifier.startQuiz();

    await notifier.answerKnew();
    expect(container.read(quizPageProvider).index, 1);
    expect(container.read(quizPageProvider).okCount, 1);
    expect(container.read(quizPageProvider).phase, QuizPhase.active);

    await notifier.answerKnew();
    expect(container.read(quizPageProvider).okCount, 2);
    expect(container.read(quizPageProvider).phase, QuizPhase.done);
    expect(container.read(quizPageProvider).forgotWords, isEmpty);
  });

  test('answerForgot で単語が学習中に戻り forgotWords に追加される', () async {
    final container = await setupLearned(1);
    final notifier = container.read(quizPageProvider.notifier);
    notifier.startQuiz();
    final target = container.read(quizPageProvider).questions.single;

    await notifier.answerForgot();

    // DB 上で学習中(isLearned=false)に戻っている。
    final word = (await db.wordDao.watchAll().first).single;
    expect(word.isLearned, isFalse);

    final state = container.read(quizPageProvider);
    expect(state.phase, QuizPhase.done);
    expect(state.okCount, 0);
    expect(state.forgotWords.map((w) => w.id), [target.id]);
  });

  test('reveal で revealed が true になる', () async {
    final container = await setupLearned(1);
    final notifier = container.read(quizPageProvider.notifier);
    notifier.startQuiz();

    notifier.reveal();

    expect(container.read(quizPageProvider).revealed, isTrue);
  });
}
