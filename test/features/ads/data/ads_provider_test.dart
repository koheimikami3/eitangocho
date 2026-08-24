import 'dart:async';

import 'package:eitangocho/features/ads/data/ads_provider.dart';
import 'package:eitangocho/features/ads/data/tracking_client.dart';
import 'package:eitangocho/features/purchase/data/purchase_notifier.dart';
import 'package:eitangocho/features/purchase/data/purchases_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../purchase/fake_purchases_client.dart';
import '../fake_tracking_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePurchasesClient client;
  late FakeTrackingClient tracking;

  setUp(() {
    // 広告は iOS のみ。macOS のままでは購入状態を見る前に false で返る。
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    client = FakePurchasesClient(initialProUnlocked: true);
    tracking = FakeTrackingClient();
  });

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    await client.dispose();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        purchasesClientProvider.overrideWithValue(client),
        trackingClientProvider.overrideWithValue(tracking),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('Pro を購入済みなら ATT も SDK の初期化もせずに広告を止める', () async {
    final container = createContainer();

    // ここで true になると広告 SDK に触れる。テスト実行機にはプラグインが
    // 無いため、そもそも例外になる。
    expect(await container.read(adsEnabledProvider.future), isFalse);
    expect(container.read(purchaseProvider).proUnlocked, isTrue);
    expect(tracking.requestCount, 0);
  });

  test('購入状態が確定するまで ATT を要求しない', () async {
    // entitlement が届くのを遅らせて、確定前に ATT を聞かないことを見る。
    // 待たずに読むと proUnlocked の初期値 false を鵜呑みにしてしまい、
    // Pro 購入者にもトラッキング許可を求めることになる。
    final configured = Completer<void>();
    client.configureGate = configured;
    final container = createContainer();

    final enabled = container.read(adsEnabledProvider.future);
    await pumpEventQueue();
    expect(tracking.isSettledCount, 0);
    expect(tracking.requestCount, 0);

    configured.complete();

    expect(await enabled, isFalse);
    expect(tracking.requestCount, 0);
  });
}
