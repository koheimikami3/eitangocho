import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/presentation/all_words_view.dart';
import 'package:eitangocho/features/word/presentation/widgets/learned_checkbox.dart';
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
  // ツリーを差し替えて破棄させることでこれを回避する。
  Future<void> runWithView(
    WidgetTester tester,
    Future<void> Function() body,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: AllWordsView())),
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

  testWidgets('登録済みの単語が行として表示される', (tester) async {
    await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), meaning: Value('りんご')),
    );
    await db.wordDao.insertWord(
      const WordsCompanion(word: Value('orange'), meaning: Value('オレンジ')),
    );

    await runWithView(tester, () async {
      expect(find.text('apple'), findsOneWidget);
      expect(find.text('orange'), findsOneWidget);
    });
  });

  testWidgets('検索クエリで行が絞り込まれる', (tester) async {
    await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), meaning: Value('りんご')),
    );
    await db.wordDao.insertWord(
      const WordsCompanion(word: Value('orange'), meaning: Value('オレンジ')),
    );

    await runWithView(tester, () async {
      container.read(mainPageProvider.notifier).updateSearchQuery('app');
      await tester.pump();

      expect(find.text('apple'), findsOneWidget);
      expect(find.text('orange'), findsNothing);
    });
  });

  testWidgets('学習済みチェックで isLearned が反転する', (tester) async {
    await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), meaning: Value('りんご')),
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
