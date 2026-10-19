import 'dart:async';

import 'package:eitangocho/components/mobile_pressable.dart';
import 'package:eitangocho/features/purchase/data/purchase_notifier.dart';
import 'package:eitangocho/features/purchase/data/purchases_client.dart';
import 'package:eitangocho/features/purchase/presentation/mobile_pro_section.dart';
import 'package:eitangocho/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fake_purchases_client.dart';

void main() {
  late FakePurchasesClient client;

  setUp(() => client = FakePurchasesClient());
  tearDown(() async => client.dispose());

  /// メッセージの一時表示は本番 2.6 秒。テストでは待てないので縮める。
  const messageDuration = Duration(milliseconds: 10);

  Future<void> pumpSection(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          purchasesClientProvider.overrideWithValue(client),
          purchaseProvider.overrideWith(
            () => PurchaseNotifier(messageDuration: messageDuration),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: MobileProSection()),
        ),
      ),
    );
    // build 内の初期化(configure → 購読 → 価格取得)を終わらせる。
    await tester.pump();
    await tester.pump();
  }

  testWidgets('未購入なら価格と購入ボタンを出す', (tester) async {
    await pumpSection(tester);

    expect(find.text('開発者にコーヒーを1杯差し入れ\u00a0☕'), findsOneWidget);
    expect(find.text('お礼に広告を非表示にします'), findsOneWidget);
    expect(find.text('買い切り ¥600'), findsOneWidget);
    expect(find.text('購入'), findsOneWidget);
    expect(find.text('購入を復元'), findsOneWidget);
  });

  testWidgets('購入済みならボタンを押せなくする', (tester) async {
    client.initialProUnlocked = true;
    await pumpSection(tester);

    // 購入済みならお礼の 1 行だけにし、お礼の内容と価格は出さない。
    expect(find.text('コーヒーありがとうございます!'), findsOneWidget);
    expect(find.text('お礼に広告を非表示にします'), findsNothing);
    expect(find.text('買い切り ¥600'), findsNothing);
    expect(find.text('購入済み'), findsOneWidget);

    await tester.tap(find.text('購入済み'));
    await tester.pump();

    expect(client.purchaseCount, 0);
  });

  testWidgets('購入すると表示が購入済みに変わる', (tester) async {
    await pumpSection(tester);

    await tester.tap(find.text('購入'));
    await tester.pump();
    await tester.pump();

    expect(client.purchaseCount, 1);
    expect(find.text('コーヒーありがとうございます!'), findsOneWidget);
    expect(find.text('購入済み'), findsOneWidget);
  });

  testWidgets('購入処理中はインジケータを出し、二重に購入しない', (tester) async {
    client.purchaseGate = Completer<void>();
    await pumpSection(tester);

    await tester.tap(find.text('購入'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(CircularProgressIndicator));
    await tester.pump();

    expect(client.purchaseCount, 1);

    client.purchaseGate!.complete();
    await tester.pump();
    await tester.pump();

    expect(find.text('購入済み'), findsOneWidget);
  });

  testWidgets('購入 → 処理中 → 購入済みでボタンの大きさが変わらない', (tester) async {
    client.purchaseGate = Completer<void>();
    await pumpSection(tester);

    Size buttonSize(Finder content) => tester.getSize(
      find.ancestor(of: content, matching: find.byType(MobilePressable)).first,
    );

    final before = buttonSize(find.text('購入'));

    await tester.tap(find.text('購入'));
    await tester.pump();
    final purchasing = buttonSize(find.byType(CircularProgressIndicator));

    client.purchaseGate!.complete();
    await tester.pump();
    await tester.pump();
    final after = buttonSize(find.text('購入済み'));

    expect(purchasing, before);
    expect(after, before);
  });

  testWidgets('購入に失敗するとその場に出して、しばらくして消す', (tester) async {
    client.purchaseOutcome = PurchaseOutcome.failed;
    await pumpSection(tester);

    await tester.tap(find.text('購入'));
    await tester.pump();
    await tester.pump();

    expect(find.text('購入できませんでした'), findsOneWidget);
    // 差し替えるのは価格の行だけで、お礼の行は残す。
    expect(find.text('お礼に広告を非表示にします'), findsOneWidget);

    await tester.pump(messageDuration * 2);

    expect(find.text('購入できませんでした'), findsNothing);
    expect(find.text('買い切り ¥600'), findsOneWidget);
  });

  testWidgets('価格を取得できないときは購入させない', (tester) async {
    client.priceText = null;
    await pumpSection(tester);

    expect(find.text('価格を取得できませんでした'), findsOneWidget);

    await tester.tap(find.text('購入'));
    await tester.pump();

    expect(client.purchaseCount, 0);
  });

  testWidgets('復元すると結果を行の右端に出す', (tester) async {
    client.restoreResult = true;
    await pumpSection(tester);

    await tester.tap(find.text('購入を復元'));
    await tester.pump();
    await tester.pump();

    expect(find.text('復元しました'), findsOneWidget);
    expect(find.text('コーヒーありがとうございます!'), findsOneWidget);

    await tester.pump(messageDuration * 2);

    expect(find.text('復元しました'), findsNothing);
  });

  testWidgets('購入履歴が無ければその旨を出す', (tester) async {
    await pumpSection(tester);

    await tester.tap(find.text('購入を復元'));
    await tester.pump();
    await tester.pump();

    expect(find.text('購入履歴が見つかりません'), findsOneWidget);

    await tester.pump(messageDuration * 2);
  });

  testWidgets('購入済みでも復元は押せる(機種変更後の導線のため)', (tester) async {
    client.initialProUnlocked = true;
    client.restoreResult = true;
    await pumpSection(tester);

    await tester.tap(find.text('購入を復元'));
    await tester.pump();
    await tester.pump();

    expect(client.restoreCount, 1);

    await tester.pump(messageDuration * 2);
  });
}
