import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/word_registration/domain/word_info.dart';
import 'package:eitangocho/features/word_registration/domain/word_info_provider.dart';
import 'package:eitangocho/features/word_registration/data/dictionary_word_info_provider.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_sheet.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../ads/ads_test_overrides.dart';
import '../../purchase/purchase_test_overrides.dart';
import '../../review/review_test_overrides.dart';

/// 常に同じ結果を返す WordInfoProvider(ネットワークに出ないため)。
class _FakeWordInfoProvider implements WordInfoProvider {
  _FakeWordInfoProvider(this.result);

  final WordInfo result;

  @override
  Future<WordInfo> fetch(String word) async => result;
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  /// iOS を装って登録シートを開く。debug 変数はテスト本体の中で戻す。
  Future<void> runSheet(
    WidgetTester tester,
    WordInfo fetched,
    Future<void> Function() body,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        wordInfoProviderProvider.overrideWithValue(
          _FakeWordInfoProvider(fetched),
        ),
        adsDisabled,
        purchasesDisabled,
        reviewDisabled,
      ],
    );
    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showWordRegistrationSheet(context),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await body();
    } finally {
      container.dispose();
      debugDefaultTargetPlatformOverride = null;
    }
  }

  const fetched = WordInfo(
    word: 'serendipity',
    ipa: '/ˌserənˈdɪpəti/',
    japanese: '偶然の幸運',
    partsOfSpeech: [PartOfSpeech.noun],
    exampleEn: 'Meeting her was pure serendipity.',
    exampleJa: '彼女に出会えたのは偶然の幸運だった。',
    audioUrl: '',
  );

  testWidgets('入力ステップでは単語欄と自動入力・手動入力の導線を出す', (tester) async {
    await runSheet(tester, fetched, () async {
      expect(find.text('単語を登録'), findsOneWidget);
      expect(find.text('自動入力'), findsOneWidget);
      expect(find.text('スキップして手動で入力する'), findsOneWidget);
      // フォームに進むまで「登録する」は出さない。
      expect(find.text('登録'), findsNothing);
    });
  });

  testWidgets('自動入力すると取得結果がプレフィルされ、バッジが付く', (tester) async {
    await runSheet(tester, fetched, () async {
      await tester.enterText(find.byType(TextField).first, 'serendipity');
      await tester.tap(find.text('自動入力'));
      await tester.pumpAndSettle();

      expect(find.text('登録'), findsOneWidget);
      expect(find.text('偶然の幸運'), findsOneWidget);
      // 取得できた項目には「自動入力」バッジが付く。
      expect(find.text('自動入力'), findsWidgets);
    });
  });

  testWidgets('手動入力にスキップするとフォームが空のまま開く', (tester) async {
    await runSheet(tester, fetched, () async {
      await tester.enterText(find.byType(TextField).first, 'ephemeral');
      await tester.tap(find.text('スキップして手動で入力する'));
      await tester.pumpAndSettle();

      expect(find.text('登録'), findsOneWidget);
      // 英単語は引き継ぐが、取得結果は入らない。
      expect(find.text('ephemeral'), findsOneWidget);
      expect(find.text('偶然の幸運'), findsNothing);
    });
  });

  // 英単語だけ半角英字キーボードに固定する。IPA は非 ASCII なので巻き込まない。
  testWidgets('英単語欄だけ ASCII キーボードに固定する', (tester) async {
    await runSheet(tester, fetched, () async {
      expect(
        tester.widget<TextField>(find.byType(TextField).first).keyboardType,
        TextInputType.visiblePassword,
      );

      await tester.enterText(find.byType(TextField).first, 'serendipity');
      await tester.tap(find.text('自動入力'));
      await tester.pumpAndSettle();

      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(fields[0].keyboardType, TextInputType.visiblePassword); // 英単語
      expect(fields[1].keyboardType, TextInputType.text); // 発音記号 (IPA)
    });
  });

  testWidgets('登録するとシートが閉じ、DB に保存される', (tester) async {
    await runSheet(tester, fetched, () async {
      await tester.enterText(find.byType(TextField).first, 'serendipity');
      await tester.tap(find.text('自動入力'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('登録'));
      await tester.pumpAndSettle();

      expect(find.text('単語を登録'), findsNothing);
      final saved = (await db.wordDao.getAll()).single;
      expect(saved.word, 'serendipity');
      expect(saved.japanese, '偶然の幸運');
    });
  });
}
