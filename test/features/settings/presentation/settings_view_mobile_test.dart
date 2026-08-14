import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/review/data/review_client.dart';
import 'package:eitangocho/features/settings/data/app_version_provider.dart';
import 'package:eitangocho/features/settings/data/license_list_provider.dart';
import 'package:eitangocho/features/settings/domain/author_app.dart';
import 'package:eitangocho/features/settings/presentation/license_view_mobile.dart';
import 'package:eitangocho/features/settings/presentation/settings_view_mobile.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_author_app_card.dart';
import 'package:eitangocho/features/settings/presentation/widgets/mobile_deepl_api_key_field.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../review/fake_review_client.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  /// [reviewClient] を渡さない場合は本番の実装のまま。
  Future<void> pumpSettings(
    WidgetTester tester, {
    ReviewClient? reviewClient,
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

  testWidgets('データセクションに iCloud 同期と書き出しを同居させる', (tester) async {
    await pumpSettings(tester);

    expect(find.text('データ'), findsOneWidget);
    expect(find.text('iCloud 同期'), findsOneWidget);
    expect(find.text('iCloud を使う端末同士で単語帳を同期します。'), findsOneWidget);
    expect(find.text('エクスポート'), findsOneWidget);
    expect(find.text('インポート'), findsOneWidget);
  });

  testWidgets('サポートセクションにレビュー行を出す', (tester) async {
    await pumpSettings(tester);

    expect(find.text('サポート'), findsOneWidget);
    expect(find.text('App Store でレビューを書く'), findsOneWidget);
    expect(find.text('感想やご要望はレビューでお知らせください。'), findsOneWidget);
  });

  testWidgets('作者の他のアプリにサブリスを出す', (tester) async {
    await pumpSettings(tester);

    expect(find.text('作者の他のアプリ'), findsOneWidget);
    expect(find.byType(MobileAuthorAppCard), findsOneWidget);
    expect(find.text(AuthorApp.name), findsOneWidget);
    expect(find.text(AuthorApp.tagline), findsOneWidget);
    expect(find.text(AuthorApp.availability), findsOneWidget);
    expect(find.text('入手'), findsOneWidget);
    expect(find.text('App Store が開きます。'), findsOneWidget);
  });

  testWidgets('情報セクションにバージョンとライセンスを出す', (tester) async {
    await pumpSettings(tester);

    expect(find.text('情報'), findsOneWidget);
    expect(find.text('バージョン'), findsOneWidget);
    expect(find.text('1.1.0'), findsOneWidget);
    expect(find.text('ライセンス'), findsOneWidget);
    expect(
      find.text('本アプリが利用しているオープンソースソフトウェアの一覧です。'),
      findsOneWidget,
    );
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
}
