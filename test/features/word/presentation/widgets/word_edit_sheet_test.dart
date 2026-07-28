import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/presentation/widgets/word_edit_sheet.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/foundation.dart';
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

  tearDown(() async => db.close());

  /// 単語を 1 件入れて編集シートを開く。debug 変数はテスト本体の中で戻す。
  Future<void> runSheet(
    WidgetTester tester,
    Future<void> Function(Word word) body,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await db.wordDao.insertWord(
        const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
      );
      final word = (await db.wordDao.getAll()).single;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) => Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => showWordEditSheet(context, ref, word),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await body(word);
    } finally {
      container.dispose();
      debugDefaultTargetPlatformOverride = null;
    }
  }

  testWidgets('編集シートに各項目と削除導線が出る', (tester) async {
    await runSheet(tester, (word) async {
      expect(find.text('単語を編集'), findsOneWidget);
      expect(find.text('キャンセル'), findsOneWidget);
      expect(find.text('保存'), findsOneWidget);
      // iOS では削除はここからしか到達できない。
      expect(find.text('この単語を削除'), findsOneWidget);
    });
  });

  testWidgets('保存すると入力内容が DB に反映される', (tester) async {
    await runSheet(tester, (word) async {
      await tester.enterText(find.byType(TextField).at(2), 'リンゴ');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      final updated = (await db.wordDao.getAll()).single;
      expect(updated.japanese, 'リンゴ');
      // 保存するとシートが閉じる。
      expect(find.text('単語を編集'), findsNothing);
    });
  });

  testWidgets('削除を確定すると単語が消え、シートも閉じる', (tester) async {
    await runSheet(tester, (word) async {
      // 削除ボタンはシート下部にあり、初期表示では画面外にある。
      await tester.ensureVisible(find.text('この単語を削除'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('この単語を削除'));
      await tester.pumpAndSettle();

      expect(find.text('「apple」を削除しますか?'), findsOneWidget);

      await tester.tap(find.text('削除する'));
      await tester.pumpAndSettle();

      expect(await db.wordDao.getAll(), isEmpty);
      expect(find.text('単語を編集'), findsNothing);
    });
  });

  testWidgets('削除をやめると単語は残り、シートも開いたまま', (tester) async {
    await runSheet(tester, (word) async {
      await tester.ensureVisible(find.text('この単語を削除'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('この単語を削除'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('やめる'));
      await tester.pumpAndSettle();

      expect(await db.wordDao.getAll(), hasLength(1));
      expect(find.text('単語を編集'), findsOneWidget);
    });
  });
}
