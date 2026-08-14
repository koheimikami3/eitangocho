import 'package:eitangocho/features/ads/data/ads_provider.dart';
import 'package:eitangocho/features/purchase/data/purchase_notifier.dart';
import 'package:eitangocho/features/purchase/data/purchases_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../purchase/fake_purchases_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePurchasesClient client;

  setUp(() {
    // 広告は iOS のみ。macOS のままでは購入状態を見る前に false で返る。
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    client = FakePurchasesClient(initialProUnlocked: true);
  });

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    await client.dispose();
  });

  test('Pro を購入済みなら ATT も SDK の初期化もせずに広告を止める', () async {
    final container = ProviderContainer(
      overrides: [purchasesClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    // 購入状態が入る前に読むと、まだ未購入として扱われてしまう。
    container.read(purchaseProvider);
    await pumpEventQueue();
    expect(container.read(purchaseProvider).proUnlocked, isTrue);

    // ここで true になると ATT と広告 SDK に触れる。テスト実行機には
    // どちらのプラグインも無いため、そもそも例外になる。
    expect(await container.read(adsEnabledProvider.future), isFalse);
  });
}
