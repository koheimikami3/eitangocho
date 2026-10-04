import 'package:eitangocho/features/settings/data/license_list_provider.dart';
import 'package:eitangocho/features/settings/domain/license_item.dart';
import 'package:eitangocho/features/settings/presentation/license_detail_view_mobile.dart';
import 'package:eitangocho/features/settings/presentation/license_view_mobile.dart';
import 'package:eitangocho/l10n/app_localizations.dart';
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

  Future<void> pumpList(
    WidgetTester tester, {
    List<LicenseItem> licenses = items,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [licenseListProvider.overrideWith((ref) async => licenses)],
        child: const MaterialApp(
          locale: Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LicenseViewMobile(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('パッケージ名とライセンス種別を並べる', (tester) async {
    await pumpList(tester);

    expect(find.text('ライセンス'), findsOneWidget);
    expect(find.text('alpha'), findsOneWidget);
    expect(find.text('MIT License'), findsOneWidget);
    expect(find.text('Tatoeba(例文と対訳)'), findsOneWidget);
    expect(find.text('CC BY 2.0 FR'), findsOneWidget);
    expect(find.text('この一覧はビルド時に自動生成されます。'), findsOneWidget);
  });

  testWidgets('行をタップすると全文が開く', (tester) async {
    await pumpList(tester);

    await tester.tap(find.text('Tatoeba(例文と対訳)'));
    await tester.pumpAndSettle();

    expect(find.byType(LicenseDetailViewMobile), findsOneWidget);
    expect(find.text('Tatoeba の帰属表示'), findsOneWidget);
    // 複数ライセンスを持つ場合は全部出す
    expect(find.text('2 つ目の本文'), findsOneWidget);
  });

  testWidgets('全文から戻るとライセンス一覧に戻る', (tester) async {
    await pumpList(tester);
    await tester.tap(find.text('alpha'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ライセンス').last);
    await tester.pumpAndSettle();

    expect(find.byType(LicenseDetailViewMobile), findsNothing);
    expect(find.byType(LicenseViewMobile), findsOneWidget);
  });

  testWidgets('一覧が空でも注記だけ出して落ちない', (tester) async {
    await pumpList(tester, licenses: []);

    expect(find.text('この一覧はビルド時に自動生成されます。'), findsOneWidget);
  });
}
