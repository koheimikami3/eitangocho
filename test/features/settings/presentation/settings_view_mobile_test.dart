import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/purchase/data/purchases_client.dart';
import 'package:eitangocho/features/purchase/presentation/mobile_pro_section.dart';
import 'package:eitangocho/features/review/data/review_client.dart';
import 'package:eitangocho/features/settings/data/app_version_provider.dart';
import 'package:eitangocho/features/settings/data/license_list_provider.dart';
import 'package:eitangocho/features/settings/domain/author_app.dart';
import 'package:eitangocho/features/settings/presentation/license_view_mobile.dart';
import 'package:eitangocho/features/settings/presentation/settings_view_mobile.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_author_app_row.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_deepl_api_key_field.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../purchase/fake_purchases_client.dart';
import '../../review/fake_review_client.dart';

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
  /// [reviewClient] を渡さない場合は本番の実装のまま。
  Future<void> pumpSettings(
    WidgetTester tester, {
    PurchasesClient? purchasesClient,
    ReviewClient? reviewClient,
  }) async {
    // 情報セクションは最下部にあり、既定の 800x600 では ListView が
    // 遅延生成して描画されない。全セクションが収まる高さにしておく。
    tester.view
      ..physicalSize = const Size(400, 3000)
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
          if (reviewClient != null)
            reviewClientProvider.overrideWithValue(reviewClient),
        ],
        child: const MaterialApp(home: Scaffold(body: SettingsViewMobile())),
      ),
    );
    await tester.pump();
  }

  testWidgets('表示セクションにテーマとカードの並びを小見出しでまとめる', (tester) async {
    await pumpSettings(tester);

    expect(find.text('表示'), findsOneWidget);
    expect(find.text('テーマ'), findsOneWidget);
    expect(find.text('学習中カードの並び'), findsOneWidget);
    expect(find.text('ライト'), findsOneWidget);
    expect(find.text('発音記号(IPA)を表示'), findsOneWidget);
    // 統合前の独立セクションは残っていないこと。
    expect(find.text('外観'), findsNothing);
  });

  testWidgets('データセクションは iCloud 同期と書き出しを 1 枚のカードに並べる', (tester) async {
    await pumpSettings(tester);

    expect(find.text('データ'), findsOneWidget);
    expect(find.text('iCloud 同期'), findsOneWidget);
    expect(find.text('データを書き出す'), findsOneWidget);
    expect(find.text('データを読み込む'), findsOneWidget);
    // 補足文はデザインどおり出さない。同期状態は「今すぐ同期」行の右端に出す
    // (同期 OFF ではその行ごと無いので、この場面では何も出ない)。
    expect(find.text('単語帳を JSON ファイルとして書き出し / 読み込みます。'), findsNothing);
    expect(find.text('iCloud を使う端末同士で単語帳を同期します。'), findsNothing);
    expect(find.text('今すぐ同期'), findsNothing);
  });

  testWidgets('サポートセクションにレビュー行を出す', (tester) async {
    await pumpSettings(tester);

    expect(find.text('サポート'), findsOneWidget);
    expect(find.text('App Store でレビューを書く'), findsOneWidget);
    // セクション下の説明文はデザインに無いので出さない。
    expect(find.text('感想やご要望はレビューでお知らせください。'), findsNothing);
  });

  testWidgets('作者の他のアプリを AuthorApp.all のぶんだけ出す', (tester) async {
    await pumpSettings(tester);

    expect(find.text('作者の他のアプリ'), findsOneWidget);
    expect(
      find.byType(MobileAuthorAppRow),
      findsNWidgets(AuthorApp.all.length),
    );
    for (final app in AuthorApp.all) {
      expect(find.text(app.name), findsOneWidget);
      expect(find.text(app.tagline), findsOneWidget);
    }
    // 価格と対応端末はどのアプリも同じ文言なので、本数ぶん出る。
    expect(find.text('無料 · iPhone'), findsNWidgets(AuthorApp.all.length));
    expect(find.text('入手'), findsNWidgets(AuthorApp.all.length));
    expect(find.text('App Store が開きます。'), findsNothing);
  });

  testWidgets('情報セクションにバージョンとライセンスを出す', (tester) async {
    await pumpSettings(tester);

    expect(find.text('情報'), findsOneWidget);
    expect(find.text('バージョン'), findsOneWidget);
    expect(find.text('1.1.0'), findsOneWidget);
    expect(find.text('ライセンス'), findsOneWidget);
    expect(find.text('本アプリが利用しているオープンソースソフトウェアの一覧です。'), findsNothing);
  });

  testWidgets('ライセンス行をタップすると一覧へ遷移する', (tester) async {
    await pumpSettings(tester);

    await tester.ensureVisible(find.text('ライセンス'));
    await tester.tap(find.text('ライセンス'));
    await tester.pumpAndSettle();

    expect(find.byType(LicenseViewMobile), findsOneWidget);
  });

  // 行はデザインどおり常に出す。開けない状態で SDK を叩かないことだけ担保する。
  testWidgets('App Store ID が未設定でもレビュー行は出すが SDK は呼ばない', (tester) async {
    final client = FakeReviewClient(canOpenStoreListing: false);
    await pumpSettings(tester, reviewClient: client);

    await tester.ensureVisible(find.text('App Store でレビューを書く'));
    await tester.tap(find.text('App Store でレビューを書く'));
    await tester.pump();

    expect(client.openStoreListingCount, 0);
  });

  testWidgets('レビュー行をタップすると App Store のレビュー画面を開く', (tester) async {
    final client = FakeReviewClient();
    await pumpSettings(tester, reviewClient: client);

    await tester.ensureVisible(find.text('App Store でレビューを書く'));
    await tester.tap(find.text('App Store でレビューを書く'));
    await tester.pump();

    expect(client.openStoreListingCount, 1);
  });

  // 欄そのものは残してあり(コメントアウト)、UI にだけ出さない。
  testWidgets('DeepL API キーの欄は表示しない', (tester) async {
    await pumpSettings(tester);

    expect(find.byType(MobileDeeplApiKeyField), findsNothing);
    expect(find.textContaining('DeepL'), findsNothing);
  });

  testWidgets('Pro セクションは最初のセクションより上に出す', (tester) async {
    final client = FakePurchasesClient();
    addTearDown(client.dispose);

    await pumpSettings(tester, purchasesClient: client);
    await tester.pump();

    expect(find.byType(MobileProSection), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(MobileProSection)).dy,
      lessThan(tester.getTopLeft(find.text('表示')).dy),
    );
  });

  testWidgets('課金を扱えない環境では Pro セクションを出さない', (tester) async {
    await pumpSettings(tester);

    expect(find.byType(MobileProSection), findsNothing);
    // セクションを畳んだぶんの余白も残さない(先頭は「表示」から始まる)。
    expect(tester.getTopLeft(find.text('表示')).dy, 16);
  });
}
