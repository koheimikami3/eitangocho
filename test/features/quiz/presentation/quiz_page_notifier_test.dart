import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/analytics/data/analytics_client.dart';
import 'package:eitangocho/features/analytics/domain/analytics_values.dart';
import 'package:eitangocho/features/quiz/domain/quiz_question_selection.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_notifier.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_state.dart';
import 'package:eitangocho/features/word/data/learning_words_provider.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../analytics/fake_analytics_client.dart';
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
  Future<ProviderContainer> setupLearned(
    int n, {
    FakeAnalyticsClient? analytics,
  }) async {
    for (var i = 0; i < n; i++) {
      final id = await db.wordDao.insertWord(
        WordsCompanion(word: Value('word$i'), meaning: Value('訳$i')),
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
        if (analytics != null)
          analyticsClientProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('startQuiz は学習済みから出題数分を選んで出題する', () async {
    final container = await setupLearned(quizQuestionCount + 1);

    container
        .read(quizPageProvider.notifier)
        .startQuiz(trigger: QuizTrigger.tab);

    final state = container.read(quizPageProvider);
    expect(state.phase, QuizPhase.active);
    expect(state.questions, hasLength(quizQuestionCount));
    expect(state.index, 0);
    expect(state.revealed, isFalse);
  });

  test('学習済みが 0 件だと phase が empty になる', () async {
    final container = await setupLearned(0);

    container
        .read(quizPageProvider.notifier)
        .startQuiz(trigger: QuizTrigger.tab);

    expect(container.read(quizPageProvider).phase, QuizPhase.empty);
  });

  test('answerKnew で index が進み okCount が加算され、最終問題で done になる', () async {
    final container = await setupLearned(2);
    final notifier = container.read(quizPageProvider.notifier);
    notifier.startQuiz(trigger: QuizTrigger.tab);

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
    notifier.startQuiz(trigger: QuizTrigger.tab);
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
    notifier.startQuiz(trigger: QuizTrigger.tab);

    notifier.reveal();

    expect(container.read(quizPageProvider).revealed, isTrue);
  });

  group('計測', () {
    test('始めた契機と、最後まで答えた結果を送る', () async {
      final analytics = FakeAnalyticsClient();
      final container = await setupLearned(2, analytics: analytics);
      final notifier = container.read(quizPageProvider.notifier)
        ..startQuiz(trigger: QuizTrigger.continued);

      await notifier.answerKnew();
      await notifier.answerForgot();

      expect(analytics.eventsNamed('quiz_started'), [
        // 投入したばかりの単語は一度も答えていない。
        {'trigger': 'continue', 'review_gap_bucket': '0_none'},
      ]);
      expect(analytics.eventsNamed('quiz_completed'), [
        {'ok_count': 1, 'forgot_count': 1},
      ]);
      expect(analytics.eventsNamed('quiz_abandoned'), isEmpty);
    });

    test('学習済みが 0 件なら quiz_empty_shown だけを送る', () async {
      final analytics = FakeAnalyticsClient();
      final container = await setupLearned(0, analytics: analytics);

      container
          .read(quizPageProvider.notifier)
          .startQuiz(trigger: QuizTrigger.tab);

      expect(analytics.eventsNamed('quiz_empty_shown'), hasLength(1));
      expect(analytics.eventsNamed('quiz_started'), isEmpty);
    });

    test('回の途中で別の画面へ移ると、答えた数を付けて離脱を 1 回だけ送る', () async {
      final analytics = FakeAnalyticsClient();
      final container = await setupLearned(3, analytics: analytics);
      final main = container.read(mainPageProvider.notifier);
      final notifier = container.read(quizPageProvider.notifier)
        ..startQuiz(trigger: QuizTrigger.tab);
      main.selectView(MainView.quiz);
      await notifier.answerKnew();

      main.selectView(MainView.learning);
      // 戻ってきて新しい回を始めても、前の回を二重に数えない。
      notifier.startQuiz(trigger: QuizTrigger.tab);
      main.selectView(MainView.quiz);

      expect(analytics.eventsNamed('quiz_abandoned'), [
        {'answered_count': 1},
      ]);
    });

    test('回の途中でクイズタブを押し直しても離脱として送る', () async {
      final analytics = FakeAnalyticsClient();
      final container = await setupLearned(3, analytics: analytics);
      final notifier = container.read(quizPageProvider.notifier)
        ..startQuiz(trigger: QuizTrigger.tab)
        ..startQuiz(trigger: QuizTrigger.tab);

      expect(notifier.state.phase, QuizPhase.active);
      expect(analytics.eventsNamed('quiz_abandoned'), [
        {'answered_count': 0},
      ]);
    });

    test('最後まで答えた回は、画面を移っても離脱にしない', () async {
      final analytics = FakeAnalyticsClient();
      final container = await setupLearned(1, analytics: analytics);
      final main = container.read(mainPageProvider.notifier);
      final notifier = container.read(quizPageProvider.notifier)
        ..startQuiz(trigger: QuizTrigger.tab);
      main.selectView(MainView.quiz);
      await notifier.answerKnew();

      main.selectView(MainView.learning);

      expect(analytics.eventsNamed('quiz_abandoned'), isEmpty);
    });
  });
}
