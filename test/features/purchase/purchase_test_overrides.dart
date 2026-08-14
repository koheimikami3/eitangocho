import 'package:eitangocho/features/purchase/data/purchases_client.dart';

/// 課金を無効にする Provider の差し替え。
///
/// 広告の [adsDisabled] と同じ理由で置く。iOS を装う
/// (`debugDefaultTargetPlatformOverride`)ウィジェットテストは、広告枠や設定
/// 画面を描いた時点で購入状態を見に行く。SDK キーが空の間は実装側も何もしない
/// が、キーを入れた途端にテストが RevenueCat のプラグインを叩き始めるため、
/// 購入そのものを検証するテスト以外はこれを overrides に足すこと。
final purchasesDisabled = purchasesClientProvider.overrideWithValue(
  const _DisabledPurchasesClient(),
);

/// 「課金を扱えない環境」を表すだけのクライアント。
/// `isAvailable` が false のとき他は呼ばれない、という約束を明示する。
class _DisabledPurchasesClient implements PurchasesClient {
  const _DisabledPurchasesClient();

  @override
  bool get isAvailable => false;

  @override
  Future<void> configure() => throw UnsupportedError('課金は無効');

  @override
  Stream<bool> watchProUnlocked() => throw UnsupportedError('課金は無効');

  @override
  Future<String?> fetchPriceText() => throw UnsupportedError('課金は無効');

  @override
  Future<PurchaseOutcome> purchase() => throw UnsupportedError('課金は無効');

  @override
  Future<bool> restore() => throw UnsupportedError('課金は無効');
}
