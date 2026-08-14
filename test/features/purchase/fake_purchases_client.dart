import 'dart:async';

import 'package:eitangocho/features/purchase/data/purchases_client.dart';

/// SDK に触れない [PurchasesClient]。
///
/// テストの実行機は macOS で課金プラグインの実体が無いため、購入まわりの
/// 検証はすべてこれに差し替えて行う(広告の [adsDisabled] と同じ理由)。
class FakePurchasesClient implements PurchasesClient {
  FakePurchasesClient({
    this.isAvailable = true,
    this.priceText = '¥600',
    this.initialProUnlocked = false,
    this.purchaseOutcome = PurchaseOutcome.purchased,
    this.restoreResult = false,
    this.configureError,
    this.restoreError,
  });

  @override
  final bool isAvailable;

  /// 取得できる価格。null なら「商品を引けなかった」を表す。
  String? priceText;

  /// 購読を始めた時点の購入状態。
  bool initialProUnlocked;

  PurchaseOutcome purchaseOutcome;
  bool restoreResult;

  /// 投げさせたい例外。
  Object? configureError;
  Object? restoreError;

  /// 購入を途中で止めておくための関門。App Store のダイアログが出ている間
  /// (= 処理中の表示)を再現したいテストだけ使う。
  Completer<void>? purchaseGate;

  var configureCount = 0;
  var purchaseCount = 0;
  var restoreCount = 0;

  final _updates = StreamController<bool>.broadcast();

  /// SDK 側からの更新通知(別端末での購入・返金)を模す。
  void emitProUnlocked({required bool unlocked}) => _updates.add(unlocked);

  Future<void> dispose() => _updates.close();

  @override
  Future<void> configure() async {
    configureCount++;
    if (configureError != null) throw configureError!;
  }

  @override
  Stream<bool> watchProUnlocked() async* {
    yield initialProUnlocked;
    yield* _updates.stream;
  }

  @override
  Future<String?> fetchPriceText() async => priceText;

  @override
  Future<PurchaseOutcome> purchase() async {
    purchaseCount++;
    await purchaseGate?.future;
    return purchaseOutcome;
  }

  @override
  Future<bool> restore() async {
    restoreCount++;
    if (restoreError != null) throw restoreError!;
    return restoreResult;
  }
}
