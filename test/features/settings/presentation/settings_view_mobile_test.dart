import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/purchase/data/purchases_client.dart';
import 'package:eitangocho/features/purchase/presentation/mobile_pro_section.dart';
import 'package:eitangocho/features/settings/data/app_version_provider.dart';
import 'package:eitangocho/features/settings/data/license_list_provider.dart';
import 'package:eitangocho/features/settings/presentation/license_view_mobile.dart';
import 'package:eitangocho/features/settings/presentation/settings_view_mobile.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_deepl_api_key_field.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../purchase/fake_purchases_client.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  /// [purchasesClient] を渡した回だけ Pro セクションが出る
  /// (既定の実装は SDK キーが空なので available が false になる)。
  Future<void> pumpSettings(
    WidgetTester tester, {
    PurchasesClient? purchasesClient,
  }) async {
    // 情報セクションは最下部にあり、既定の 800x600 では ListView が
    // 遅延生成して描画されない。全セクションが収まる高さにしておく。
    tester.view
      ..physicalSize = const Size(400, 2600)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          // 実機のバンドルを読むため、テストでは固定値に差し替える。
          appVersionProvider.overrideWith((ref) async => '1.1.0'),
          licenseListProvider.overrideWith((ref) async => []),
          if (purchasesClient != null)
            purchasesClientProvider.overrideWithValue(purchasesClient),
        ],
        child: const MaterialApp(home: Scaffold(body: SettingsViewMobile())),
      ),
    );
    await tester.pump();
  }

  testWidgets('情報セクションにバージョンとライセンスを出す', (tester) async {
    await pumpSettings(tester);

    expect(find.text('情報'), findsOneWidget);
    expect(find.text('バージョン'), findsOneWidget);
    expect(find.text('1.1.0'), findsOneWidget);
    expect(find.text('ライセンス'), findsOneWidget);
    expect(find.text('本アプリが利用しているオープンソースソフトウェアの一覧です。'), findsOneWidget);
  });

  testWidgets('ライセンス行をタップすると一覧へ遷移する', (tester) async {
    await pumpSettings(tester);

    await tester.ensureVisible(find.text('ライセンス'));
    await tester.tap(find.text('ライセンス'));
    await tester.pumpAndSettle();

    expect(find.byType(LicenseViewMobile), findsOneWidget);
  });

  // 欄そのものは残してあり(コメントアウト)、UI にだけ出さない。
  testWidgets('DeepL API キーの欄は表示しない', (tester) async {
    await pumpSettings(tester);

    expect(find.byType(MobileDeeplApiKeyField), findsNothing);
    expect(find.textContaining('DeepL'), findsNothing);
  });

  testWidgets('Pro セクションは外観より上に出す', (tester) async {
    final client = FakePurchasesClient();
    addTearDown(client.dispose);

    await pumpSettings(tester, purchasesClient: client);
    await tester.pump();

    expect(find.byType(MobileProSection), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(MobileProSection)).dy,
      lessThan(tester.getTopLeft(find.text('外観')).dy),
    );
  });

  testWidgets('課金を扱えない環境では Pro セクションを出さない', (tester) async {
    await pumpSettings(tester);

    expect(find.byType(MobileProSection), findsNothing);
    // セクションを畳んだぶんの余白も残さない。
    expect(tester.getTopLeft(find.text('外観')).dy, 16);
  });
}
