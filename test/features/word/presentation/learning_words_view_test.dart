import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/presentation/learning_words_view.dart';
import 'package:eitangocho/features/word/presentation/widgets/learned_checkbox.dart';
import 'package:eitangocho/features/word/presentation/widgets/learning_empty_state.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  // drift の watch() は購読解除時に Timer を発行するため、flutter_test の
  // FakeAsync ゾーン内でツリーを破棄すると「A Timer is still pending」になる
  // (drift #3323)。runAsync で実イベントループに逃がしたうえで、最後に
  // ツリーを差し替えて破棄させることでこれを回避する
  // (all_words_view_test.dart の runWithView と同じ手法)。
  Future<void> runWithView(
    WidgetTester tester,
    Future<void> Function() body,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: LearningWordsView())),
        ),
      );
      // drift の watch() の初回発火は実イベントループの Future を経由するため、
      // pump() 1 回では反映されない。
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await tester.pump();

      await body();

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await db.close();
    });
  }

  testWidgets('未学習の単語だけがカード表示される(学習済みは出ない)', (tester) async {
    await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
    );
    final learnedId = await db.wordDao.insertWord(
      const WordsCompanion(word: Value('orange'), japanese: Value('オレンジ')),
    );
    await db.wordDao.setLearned(learnedId, isLearned: true);

    await runWithView(tester, () async {
      expect(find.text('apple'), findsOneWidget);
      expect(find.text('orange'), findsNothing);
    });
  });

  testWidgets('読み込みが終わるまでは空状態ではなく読み込み中を表示する', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: LearningWordsView())),
        ),
      );
      // drift の watch() が初回発火する前(runWithView の待ちを挟まない)。
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(LearningEmptyState), findsNothing);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(LearningEmptyState), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await db.close();
    });
  });

  testWidgets('学習中が 0 件だと空状態が表示される', (tester) async {
    await runWithView(tester, () async {
      expect(find.byType(LearningEmptyState), findsOneWidget);
    });
  });

  testWidgets('「日本語訳を表示」をタップすると訳が現れる', (tester) async {
    await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
    );

    await runWithView(tester, () async {
      expect(find.text('日本語訳を表示'), findsOneWidget);
      expect(find.text('りんご'), findsNothing);

      await tester.tap(find.text('日本語訳を表示'));
      await tester.pump();

      expect(find.text('りんご'), findsOneWidget);
    });
  });

  testWidgets('学習済みチェックで isLearned が true になりカードから消える', (tester) async {
    await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
    );

    await runWithView(tester, () async {
      await tester.tap(find.byType(LearnedCheckbox));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await tester.pump();

      final words = await db.wordDao.watchAll().first;
      expect(words.single.isLearned, isTrue);
    });
  });
}
