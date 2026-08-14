import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_learning_empty_state.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../ads/ads_test_overrides.dart';
import '../../../purchase/purchase_test_overrides.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  testWidgets('登録ボタンで登録シートが開く(ビュー切替の行き止まりにならない)', (tester) async {
    // シートは iOS 用の表示なので、プラットフォームを装ってから開く。
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        adsDisabled,
        purchasesDisabled,
      ],
    );
    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: MobileLearningEmptyState()),
          ),
        ),
      );

      await tester.tap(find.text('＋ 単語を登録'));
      await tester.pumpAndSettle();

      // 登録シートの入力ステップが出ていれば、導線が繋がっている。
      expect(find.text('自動入力'), findsOneWidget);
      expect(find.text('スキップして手動で入力する'), findsOneWidget);
    } finally {
      container.dispose();
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
