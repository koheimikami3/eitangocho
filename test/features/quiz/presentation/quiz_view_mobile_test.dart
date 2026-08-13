import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_notifier.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_view_mobile.dart';
import 'package:eitangocho/features/word/data/learning_words_provider.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../ads/ads_test_overrides.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // 設定(出題方向)を読むため、インメモリの SharedPreferences を差し込む。
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  /// 学習済み単語を投入し、learnedWordsProvider を静的リストに差し替えた
  /// container を返す。drift の watch() ストリーム(wordListProvider)を
  /// 購読させないことで、破棄時の購読解除タイマー衝突(drift #3323)を避ける
  /// (quiz_page_notifier_test.dart と同じ手法)。
  Future<ProviderContainer> setupLearned(List<(String, String)> words) async {
    for (final (word, japanese) in words) {
      final id = await db.wordDao.insertWord(
        WordsCompanion(
          word: Value(word),
          japanese: Value(japanese),
          exampleEn: const Value('An example sentence.'),
          exampleJa: const Value('例文です。'),
        ),
      );
      await db.wordDao.setLearned(id, isLearned: true);
    }
    final learned = (await db.wordDao.getAll())
        .where((w) => w.isLearned)
        .toList();
    return ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        learnedWordsProvider.overrideWithValue(learned),
        adsDisabled,
      ],
    );
  }

  /// iOS を装ってクイズ画面を描画する。debug 変数はテスト本体の中で戻す
  /// (flutter_test が本体直後に未設定へ戻っていることを検証するため)。
  Future<void> runQuiz(
    WidgetTester tester,
    ProviderContainer container,
    Future<void> Function() body,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: QuizViewMobile())),
        ),
      );
      await tester.pump();
      await body();
    } finally {
      container.dispose();
      debugDefaultTargetPlatformOverride = null;
    }
  }

  testWidgets('学習済みが 0 件なら空状態を出す', (tester) async {
    final container = await setupLearned([]);

    await runQuiz(tester, container, () async {
      expect(find.textContaining('復習対象の単語がまだありません'), findsOneWidget);
      expect(find.text('学習中リストへ'), findsOneWidget);
    });
  });

  testWidgets('出題中は表面と「答えを表示」を出し、答えると裏面と判定ボタンになる', (tester) async {
    final container = await setupLearned([('serendipity', '偶然の幸運')]);
    container.read(quizPageProvider.notifier).startQuiz();

    await runQuiz(tester, container, () async {
      // 表面(既定は en→ja なので英単語)と進捗。
      expect(find.text('serendipity'), findsOneWidget);
      expect(find.text('1 / 1'), findsOneWidget);
      expect(find.text('偶然の幸運'), findsNothing);

      await tester.tap(find.text('答えを表示'));
      await tester.pump();

      expect(find.text('偶然の幸運'), findsOneWidget);
      expect(find.text('覚えている'), findsOneWidget);
      expect(find.text('忘れていた'), findsOneWidget);
    });
  });

  testWidgets('全問終えると結果画面になり、忘れた単語が一覧に出る', (tester) async {
    final container = await setupLearned([('serendipity', '偶然の幸運')]);
    container.read(quizPageProvider.notifier).startQuiz();

    await runQuiz(tester, container, () async {
      await tester.tap(find.text('答えを表示'));
      await tester.pump();
      await tester.tap(find.text('忘れていた'));
      await tester.pump();

      expect(find.text('復習完了'), findsOneWidget);
      expect(find.text('覚えている 0語 / 忘れていた 1語'), findsOneWidget);
      expect(find.text('忘れていた単語(学習中リストに戻りました)'), findsOneWidget);
      expect(find.text('もう一度'), findsOneWidget);
    });
  });
}
