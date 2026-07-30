import 'package:eitangocho/app/eitangocho_app.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/data/word_list_provider.dart';
import 'package:eitangocho/features/word_registration/data/ejdict_importer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Size;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    // 設定画面(SettingsView)は SharedPreferencesAsync を直接使うため、
    // インメモリ実装を差し込まないとタブ切替で例外になる。
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  // wordListProvider は drift の watch() ストリームを直接公開しており、
  // widget テスト終了時の暗黙的破棄で drift 側の購読解除タイマーと
  // flutter_test の "pending timer" 検査が衝突するため、シェルの表示のみを
  // 検証するこのテストでは静的な Stream に差し替えて DB に触れないようにする。
  //
  // シェルはプラットフォームで分岐するため、どちらを検証するかを明示する。
  // debug 変数はテスト本体の中で戻す必要がある(flutter_test が本体直後に
  // 未設定へ戻っていることを検証するため)。
  Future<void> runApp(
    WidgetTester tester,
    TargetPlatform platform, {
    required Size physicalSize,
    required double devicePixelRatio,
    required Future<void> Function() body,
  }) async {
    debugDefaultTargetPlatformOverride = platform;
    tester.view.physicalSize = physicalSize;
    tester.view.devicePixelRatio = devicePixelRatio;
    addTearDown(tester.view.reset);
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            wordListProvider.overrideWith(
              (ref) => Stream.value(const <Word>[]),
            ),
            // MainPage が起動時にキックする EJDict 取込も DB に触れるため差し替える。
            ejdictImportProvider.overrideWith((ref) async => 0),
          ],
          child: const EitangochoApp(),
        ),
      );
      await tester.pumpAndSettle();
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  /// macOS: 既定のテスト画面(800x600)は uiScale で拡大すると実質幅が狭く
  /// ツールバーが溢れるため、実際のウィンドウに近いサイズにする。
  Future<void> runDesktop(
    WidgetTester tester,
    Future<void> Function() body,
  ) => runApp(
    tester,
    TargetPlatform.macOS,
    physicalSize: const Size(1600, 1000),
    devicePixelRatio: 1,
    body: body,
  );

  /// iOS: iPhone 16 Pro 相当(論理 402x874)。
  Future<void> runMobile(
    WidgetTester tester,
    Future<void> Function() body,
  ) => runApp(
    tester,
    TargetPlatform.iOS,
    physicalSize: const Size(1206, 2622),
    devicePixelRatio: 3,
    body: body,
  );

  group('macOS(サイドバー版)', () {
    testWidgets('サイドバーの項目とツールバーのタイトルが表示される', (tester) async {
      await runDesktop(tester, () async {
        // 既定は学習中ビュー。サイドバー項目が一通り並ぶ。
        expect(find.text('単語帳'), findsOneWidget);
        expect(find.text('学習中'), findsOneWidget);
        expect(find.text('全単語'), findsOneWidget);
        expect(find.text('フラッシュクイズ'), findsOneWidget);
        expect(find.text('設定'), findsOneWidget);
        expect(find.text('ローカル DB に保存済み'), findsOneWidget);
        // 単語を登録: サイドバー項目のみ(既定タイトルは「学習中の単語」)。
        expect(find.text('単語を登録'), findsOneWidget);
        // ＋ 単語を登録: ツールバーボタン + 学習中の空状態の登録導線。
        expect(find.text('＋ 単語を登録'), findsNWidgets(2));
      });
    });

    testWidgets('サイドバー項目クリックでビューが切り替わる', (tester) async {
      await runDesktop(tester, () async {
        await tester.tap(find.text('単語を登録').first);
        await tester.pumpAndSettle();

        // 登録ビューに切り替わるとサイドバー項目 + ツールバータイトルの 2 箇所になる。
        expect(find.text('単語を登録'), findsNWidgets(2));
      });
    });
  });

  group('iOS(タブバー版)', () {
    testWidgets('タブバーの 4 項目とヘッダが表示され、サイドバーは出ない', (tester) async {
      await runMobile(tester, () async {
        // タブは 4 つ。単語登録はタブに置かない。
        expect(find.text('全単語'), findsOneWidget);
        expect(find.text('クイズ'), findsOneWidget);
        expect(find.text('設定'), findsOneWidget);
        // 「学習中」はヘッダのタイトルとタブラベルの 2 箇所。
        expect(find.text('学習中'), findsNWidgets(2));

        // サイドバー固有の要素は出ない。
        expect(find.text('単語帳'), findsNothing);
        expect(find.text('ローカル DB に保存済み'), findsNothing);
        // ヘッダの登録ボタンは短いラベル。
        expect(find.text('＋ 登録'), findsOneWidget);
      });
    });

    testWidgets('タブをタップするとビューが切り替わる', (tester) async {
      await runMobile(tester, () async {
        await tester.tap(find.text('設定'));
        await tester.pumpAndSettle();

        // 設定ビューではヘッダタイトルとタブラベルの 2 箇所になり、
        // 検索欄と登録ボタンは消える。
        expect(find.text('設定'), findsNWidgets(2));
        expect(find.text('＋ 登録'), findsNothing);
      });
    });
  });

  // ⌘N/⌘F は macOS のネイティブメニューバー(AppMenuBar / PlatformMenuBar)経由で
  // 処理する。native ⌘ 発火は widget test の sendKeyEvent では再現できないため、
  // メニューの配線・有効/無効・発火先の検証は app_menu_bar_test.dart で行う。
}
