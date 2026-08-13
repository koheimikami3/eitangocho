import 'package:eitangocho/features/purchase/data/purchase_notifier.dart';
import 'package:eitangocho/features/purchase/data/purchases_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fake_purchases_client.dart';

void main() {
  // Riverpod の Provider を読むだけでも binding が要る。
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePurchasesClient client;

  setUp(() => client = FakePurchasesClient());
  tearDown(() async => client.dispose());

  /// [messageDuration] は本番の 2.6 秒だとテストが待てないため縮める。
  ProviderContainer makeContainer({
    Duration messageDuration = const Duration(milliseconds: 10),
  }) {
    final container = ProviderContainer(
      overrides: [
        purchasesClientProvider.overrideWithValue(client),
        purchaseProvider.overrideWith(
          () => PurchaseNotifier(messageDuration: messageDuration),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// build 内の初期化(configure → 購読 → 価格取得)が終わるまで待つ。
  Future<ProviderContainer> initialized({
    Duration messageDuration = const Duration(milliseconds: 10),
  }) async {
    final container = makeContainer(messageDuration: messageDuration);
    container.read(purchaseProvider);
    await pumpEventQueue();
    return container;
  }

  test('初期化すると価格が入り、購入できる状態になる', () async {
    final container = await initialized();

    final state = container.read(purchaseProvider);
    expect(state.available, isTrue);
    expect(state.priceText, '¥600');
    expect(state.proUnlocked, isFalse);
    expect(client.configureCount, 1);
  });

  test('課金を扱えない環境では SDK に触れない', () async {
    client = FakePurchasesClient(isAvailable: false);
    final container = await initialized();

    expect(container.read(purchaseProvider).available, isFalse);
    expect(client.configureCount, 0);

    await container.read(purchaseProvider.notifier).buy();

    expect(client.purchaseCount, 0);
  });

  test('初期化に失敗したら Pro セクションごと畳む', () async {
    client.configureError = Exception('設定に失敗');
    final container = await initialized();

    expect(container.read(purchaseProvider).available, isFalse);
  });

  test('購入済みの状態は起動時に復元される', () async {
    client.initialProUnlocked = true;
    final container = await initialized();

    expect(container.read(purchaseProvider).proUnlocked, isTrue);
  });

  test('購入に成功すると Pro になる', () async {
    final container = await initialized();

    await container.read(purchaseProvider.notifier).buy();

    final state = container.read(purchaseProvider);
    expect(state.proUnlocked, isTrue);
    expect(state.purchasing, isFalse);
    expect(state.purchaseMessage, isNull);
  });

  test('購入をキャンセルしても何も表示しない', () async {
    client.purchaseOutcome = PurchaseOutcome.cancelled;
    final container = await initialized();

    await container.read(purchaseProvider.notifier).buy();

    final state = container.read(purchaseProvider);
    expect(state.proUnlocked, isFalse);
    expect(state.purchaseMessage, isNull);
  });

  test('購入に失敗するとメッセージを出し、しばらくして消す', () async {
    client.purchaseOutcome = PurchaseOutcome.failed;
    final container = await initialized();

    await container.read(purchaseProvider.notifier).buy();

    expect(container.read(purchaseProvider).purchaseMessage, '購入できませんでした');

    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(container.read(purchaseProvider).purchaseMessage, isNull);
  });

  test('価格が取れていないときは購入させない', () async {
    client.priceText = null;
    final container = await initialized();

    await container.read(purchaseProvider.notifier).buy();

    expect(client.purchaseCount, 0);
  });

  test('購入済みなら二重に購入しない', () async {
    client.initialProUnlocked = true;
    final container = await initialized();

    await container.read(purchaseProvider.notifier).buy();

    expect(client.purchaseCount, 0);
  });

  test('復元に成功すると Pro になる', () async {
    client.restoreResult = true;
    final container = await initialized();

    await container.read(purchaseProvider.notifier).restore();

    final state = container.read(purchaseProvider);
    expect(state.proUnlocked, isTrue);
    expect(state.restoreMessage, '復元しました');
    expect(state.restoring, isFalse);
  });

  test('購入履歴が無ければその旨を出す', () async {
    final container = await initialized();

    await container.read(purchaseProvider.notifier).restore();

    final state = container.read(purchaseProvider);
    expect(state.proUnlocked, isFalse);
    expect(state.restoreMessage, '購入履歴が見つかりません');
  });

  test('復元に失敗してもアプリは動き続ける', () async {
    client.restoreError = Exception('通信に失敗');
    final container = await initialized();

    await container.read(purchaseProvider.notifier).restore();

    final state = container.read(purchaseProvider);
    expect(state.restoreMessage, '復元できませんでした');
    expect(state.restoring, isFalse);
  });

  test('SDK の更新通知(別端末での購入・返金)に追従する', () async {
    final container = await initialized();

    client.emitProUnlocked(unlocked: true);
    await pumpEventQueue();

    expect(container.read(purchaseProvider).proUnlocked, isTrue);

    client.emitProUnlocked(unlocked: false);
    await pumpEventQueue();

    expect(container.read(purchaseProvider).proUnlocked, isFalse);
  });
}
