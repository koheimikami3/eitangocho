import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/settings/presentation/settings_view.dart';
import 'package:eitangocho/features/settings/presentation/widgets/ui_scale_slider.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  /// [platform] を装って設定画面を描画する。debug 変数の後始末は
  /// word_card_test.dart と同じ理由でテスト本体の中(finally)で行う。
  Future<void> runForPlatform(
    WidgetTester tester,
    TargetPlatform platform,
    Future<void> Function() body,
  ) async {
    debugDefaultTargetPlatformOverride = platform;
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const MaterialApp(home: Scaffold(body: SettingsView())),
        ),
      );
      await tester.pump();
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  // 表示サイズ(uiScale)は EitangochoApp が UI 全体を Transform.scale する
  // macOS 専用の機能。iOS では OS の文字サイズ設定に委ねるため出さない。
  testWidgets('macOS では表示サイズのスライダーを出す', (tester) async {
    await runForPlatform(tester, TargetPlatform.macOS, () async {
      expect(find.byType(UiScaleSlider), findsOneWidget);
    });
  });

  testWidgets('iOS では表示サイズのスライダーを出さない', (tester) async {
    await runForPlatform(tester, TargetPlatform.iOS, () async {
      expect(find.byType(UiScaleSlider), findsNothing);
      // 同じ「表示」セクションの他項目は残っていること。
      expect(find.text('発音記号(IPA)を表示'), findsOneWidget);
    });
  });
}
