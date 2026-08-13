import 'package:eitangocho/features/settings/data/license_list_provider.dart';
import 'package:eitangocho/features/settings/domain/license_item.dart';
import 'package:eitangocho/features/settings/presentation/license_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const items = [
    LicenseItem(name: 'alpha', summary: 'MIT License', texts: ['MIT 本文']),
    LicenseItem(
      name: 'Tatoeba(例文と対訳)',
      summary: 'CC BY 2.0 FR',
      texts: ['Tatoeba の帰属表示', '2 つ目の本文'],
    ),
  ];

  /// ダイアログを開いた状態にする。
  Future<void> openDialog(
    WidgetTester tester, {
    List<LicenseItem> licenses = items,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [licenseListProvider.overrideWith((ref) async => licenses)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showLicenseDialog(context),
                child: const Text('開く'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('開く'));
    await tester.pumpAndSettle();
  }

  testWidgets('パッケージ名とライセンス種別を並べる', (tester) async {
    await openDialog(tester);

    expect(find.text('ライセンス'), findsOneWidget);
    expect(find.text('alpha'), findsOneWidget);
    expect(find.text('MIT License'), findsOneWidget);
    expect(find.text('Tatoeba(例文と対訳)'), findsOneWidget);
    expect(find.text('この一覧はビルド時に自動生成されます。'), findsOneWidget);
  });

  // 全文は別画面にせず、同じダイアログ内で入れ替える。
  testWidgets('行をクリックすると同じダイアログ内で全文に切り替わる', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('Tatoeba(例文と対訳)'));
    await tester.pumpAndSettle();

    // ヘッダのタイトルが項目名に変わり、一覧は消える
    expect(find.text('alpha'), findsNothing);
    expect(find.text('Tatoeba の帰属表示'), findsOneWidget);
    expect(find.text('2 つ目の本文'), findsOneWidget);
    expect(find.text('戻る'), findsOneWidget);
  });

  testWidgets('全文から「戻る」で一覧に戻る', (tester) async {
    await openDialog(tester);
    await tester.tap(find.text('alpha'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('戻る'));
    await tester.pumpAndSettle();

    expect(find.text('alpha'), findsOneWidget);
    expect(find.text('MIT 本文'), findsNothing);
    expect(find.text('戻る'), findsNothing);
  });

  testWidgets('「閉じる」でダイアログを閉じる', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('閉じる'));
    await tester.pumpAndSettle();

    expect(find.text('ライセンス'), findsNothing);
  });

  testWidgets('一覧が空でも注記だけ出して落ちない', (tester) async {
    await openDialog(tester, licenses: []);

    expect(find.text('この一覧はビルド時に自動生成されます。'), findsOneWidget);
  });
}
