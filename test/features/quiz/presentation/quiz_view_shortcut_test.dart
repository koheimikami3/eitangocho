import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_page_notifier.dart';
import 'package:eitangocho/features/quiz/presentation/quiz_view.dart';
import 'package:eitangocho/features/word/data/learning_words_provider.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // QuizView は settingsProvider(quizDirection)を watch するため、
    // SharedPreferencesAsync のインメモリ実装を差し込んでおく
    // (settings_notifier_test.dart と同じ方針)。
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  // drift の watch() は購読解除時に Timer を発行するため、flutter_test の
  // FakeAsync ゾーン内でツリーを破棄すると「A Timer is still pending」に
  // なりハングする(drift #3323)。runAsync で実イベントループに逃がし、
  // 最後にツリーを差し替えて破棄する(all_words_view_test.dart の
  // runWithView と同じ方針)。
  Future<void> runWithQuiz(
    WidgetTester tester,
    int wordCount,
    Future<void> Function() body,
  ) async {
    await tester.runAsync(() async {
      for (var i = 0; i < wordCount; i++) {
        final id = await db.wordDao.insertWord(
          WordsCompanion(word: Value('word$i'), japanese: Value('訳$i')),
        );
        await db.wordDao.setLearned(id, isLearned: true);
      }
      final learned = (await db.wordDao.watchAll().first)
          .where((w) => w.isLearned)
          .toList();
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          learnedWordsProvider.overrideWithValue(learned),
        ],
      );
      container.read(quizPageProvider.notifier).startQuiz();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          // MaterialApp 既定のグローバルショートカット(矢印キーのフォーカス
          // トラバーサル等)がテストの意図しない干渉を起こさないよう無効化する。
          child: const MaterialApp(
            shortcuts: <ShortcutActivator, Intent>{},
            home: Scaffold(body: QuizView()),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await tester.pump();

      await body();

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await db.close();
    });
  }

  testWidgets('Space で答えが開示される', (tester) async {
    await runWithQuiz(tester, 1, () async {
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(container.read(quizPageProvider).revealed, isTrue);
    });
  });

  testWidgets('開示後に → で「覚えている」として次に進む', (tester) async {
    await runWithQuiz(tester, 2, () async {
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await tester.pump();

      expect(container.read(quizPageProvider).index, 1);
      expect(container.read(quizPageProvider).okCount, 1);
    });
  });

  testWidgets('開示後に ← で「忘れていた」として次に進む', (tester) async {
    await runWithQuiz(tester, 2, () async {
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await tester.pump();

      expect(container.read(quizPageProvider).index, 1);
      expect(container.read(quizPageProvider).okCount, 0);
      expect(container.read(quizPageProvider).forgotWords, hasLength(1));
    });
  });

  testWidgets('開示前は ←/→ が無反応', (tester) async {
    await runWithQuiz(tester, 1, () async {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(container.read(quizPageProvider).revealed, isFalse);
      expect(container.read(quizPageProvider).index, 0);
    });
  });
}
