import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/review/data/review_client.dart';
import 'package:eitangocho/features/settings/data/app_version_provider.dart';
import 'package:eitangocho/features/settings/data/license_list_provider.dart';
import 'package:eitangocho/features/settings/presentation/settings_view.dart';
import 'package:eitangocho/features/settings/presentation/widgets/ui_scale_slider.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/foundation.dart';
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

  /// [platform] を装って設定画面を描画する。debug 変数の後始末は
  /// word_card_test.dart と同じ理由でテスト本体の中(finally)で行う。
  /// [reviewClient] を渡さない場合は本番の実装のまま。
  Future<void> runForPlatform(
    WidgetTester tester,
    TargetPlatform platform,
    Future<void> Function() body, {
    ReviewClient? reviewClient,
  }) async {
    // 情報セクションは最下部にあり、既定の 800x600 では画面外に出て
    // タップが当たらない。全セクションが収まる高さにしておく。
    tester.view
      ..physicalSize = const Size(700, 1600)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    debugDefaultTargetPlatformOverride = platform;
    try {
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

  testWidgets('データセクションは iCloud 同期と書き出しを 1 枚のカードに並べる', (tester) async {
    await runForPlatform(tester, TargetPlatform.macOS, () async {
      expect(find.text('データ'), findsOneWidget);
      expect(find.text('iCloud 同期'), findsOneWidget);
      // 末尾の `...` は macOS だけに付ける(ダイアログが開くことを示す慣習)。
      expect(find.text('データを書き出す...'), findsOneWidget);
      expect(find.text('データを読み込む...'), findsOneWidget);
      // 補足文はデザインどおり出さない。同期状態は「今すぐ同期」行の右端に出す
      // (同期 OFF ではその行ごと無いので、この場面では何も出ない)。
      expect(find.text('単語帳を JSON ファイルとして書き出し / 読み込みます。'), findsNothing);
      expect(find.text('iCloud を使う端末同士で単語帳を同期します。'), findsNothing);
      expect(find.text('今すぐ同期'), findsNothing);
    });
  });

  testWidgets('サポートセクションにレビュー行を出す', (tester) async {
    await runForPlatform(tester, TargetPlatform.macOS, () async {
      expect(find.text('サポート'), findsOneWidget);
      expect(find.text('App Store でレビューを書く'), findsOneWidget);
      // セクション下の説明文はデザインに無いので出さない。
      expect(find.text('感想やご要望はレビューでお知らせください。'), findsNothing);
    });
  });

  testWidgets('情報セクションにバージョンとライセンスを出す', (tester) async {
    await runForPlatform(tester, TargetPlatform.macOS, () async {
      expect(find.text('情報'), findsOneWidget);
      expect(find.text('バージョン'), findsOneWidget);
      expect(find.text('1.1.0'), findsOneWidget);
      expect(find.text('ライセンス'), findsOneWidget);
      expect(find.text('本アプリが利用しているオープンソースソフトウェアの一覧です。'), findsNothing);
    });
  });

  testWidgets('ライセンス行のクリックでモーダルが開く', (tester) async {
    await runForPlatform(tester, TargetPlatform.macOS, () async {
      await tester.tap(find.text('ライセンス'));
      await tester.pumpAndSettle();

      expect(find.text('閉じる'), findsOneWidget);
      expect(find.text('この一覧はビルド時に自動生成されます。'), findsOneWidget);
    });
  });

  // 行はデザインどおり常に出す。開けない状態で SDK を叩かないことだけ担保する。
  testWidgets('App Store ID が未設定でもレビュー行は出すが SDK は呼ばない', (tester) async {
    final client = FakeReviewClient(canOpenStoreListing: false);
    await runForPlatform(tester, TargetPlatform.macOS, () async {
      await tester.tap(find.text('App Store でレビューを書く'));
      await tester.pump();

      expect(client.openStoreListingCount, 0);
    }, reviewClient: client);
  });

  testWidgets('レビュー行のクリックで App Store のレビュー画面を開く', (tester) async {
    final client = FakeReviewClient();
    await runForPlatform(tester, TargetPlatform.macOS, () async {
      await tester.tap(find.text('App Store でレビューを書く'));
      await tester.pump();

      expect(client.openStoreListingCount, 1);
    }, reviewClient: client);
  });

  // 欄そのものは残してあり(コメントアウト)、UI にだけ出さない。
  testWidgets('DeepL API キーの欄は表示しない', (tester) async {
    await runForPlatform(tester, TargetPlatform.macOS, () async {
      expect(find.textContaining('DeepL'), findsNothing);
    });
  });
}
