import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/presentation/widgets/edit_word_dialog.dart';
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

  tearDown(() async => db.close());

  /// 単語を 1 件入れて編集ダイアログを開く(iOS 版の word_edit_sheet_test と同型)。
  Future<void> runDialog(
    WidgetTester tester,
    Future<void> Function(Word word) body,
  ) async {
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
                    onPressed: () => showEditWordDialog(context, ref, word),
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
    }
  }

  testWidgets('保存すると入力内容が DB に反映される(自分自身は重複扱いしない)', (tester) async {
    await runDialog(tester, (word) async {
      await tester.enterText(find.byType(TextField).at(2), 'リンゴ');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      expect((await db.wordDao.getAll()).single.japanese, 'リンゴ');
      // 保存するとダイアログが閉じる。
      expect(find.text('単語を編集'), findsNothing);
    });
  });

  testWidgets('既存の単語名に変更するとエラーになり、更新もされない', (tester) async {
    await runDialog(tester, (word) async {
      await db.wordDao.insertWord(
        const WordsCompanion(word: Value('banana'), japanese: Value('バナナ')),
      );

      // 大文字違いでも同じ単語とみなす。
      await tester.enterText(find.byType(TextField).first, 'Banana');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      expect(find.text('「banana」は既に登録されています。'), findsOneWidget);
      // ダイアログは開いたままで、単語名も元のまま。
      expect(find.text('単語を編集'), findsOneWidget);
      final words = await db.wordDao.getAll();
      expect(words.map((w) => w.word), containsAll(['apple', 'banana']));
    });
  });
}
