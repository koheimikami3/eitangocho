import 'dart:async';

import 'package:eitangocho/features/purchase/domain/purchase_config.dart';
import 'package:eitangocho/features/purchase/domain/purchase_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchases_client.g.dart';

/// 購入処理の結果。
enum PurchaseOutcome {
  /// entitlement が有効になった。
  purchased,

  /// ユーザーが App Store のダイアログを閉じた。無音で戻る。
  cancelled,

  /// 失敗した。メッセージを出す。
  failed,
}

/// RevenueCat SDK の呼び出しを閉じ込める抽象。
///
/// SDK の型が Notifier より上に漏れないようにする。テストではフェイクに
/// 差し替える(テストの実行機は macOS で、課金プラグインの実体が無いため)。
abstract interface class PurchasesClient {
  /// 課金を扱える環境か。false なら他の操作は呼ばれない。
  bool get isAvailable;

  /// SDK を初期化する。他の操作はこれを待ってから呼ぶ。
  Future<void> configure();

  /// Pro が解禁されているか。購読を始めた時点の値と、以後の変化が流れる。
  Stream<bool> watchProUnlocked();

  /// 買い切り商品の表示価格(ローカライズ済み)。取れなければ null。
  Future<String?> fetchPriceText();

  /// 買い切り商品を購入する。
  Future<PurchaseOutcome> purchase();

  /// 過去の購入を復元する。Pro になったかを返す。
  Future<bool> restore();
}

/// RevenueCat による実装。
class RevenueCatPurchasesClient implements PurchasesClient {
  const RevenueCatPurchasesClient();

  @override
  bool get isAvailable => PurchaseConfig.isAvailable;

  @override
  Future<void> configure() async {
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
    await Purchases.configure(
      PurchasesConfiguration(PurchaseConfig.appleApiKey),
    );
  }

  /// 購入・復元だけでなく、返金・別端末での購入・失効もここに流れる。
  ///
  /// 購入導線を通ったときにしか状態を見ない作りにすると、他端末で買った
  /// ユーザーにいつまでも広告が出る。SDK の更新通知を張り続けて追従する。
  @override
  Stream<bool> watchProUnlocked() {
    late final StreamController<bool> controller;

    void onUpdate(CustomerInfo info) {
      if (!controller.isClosed) controller.add(_isProActive(info));
    }

    controller = StreamController<bool>(
      onListen: () {
        Purchases.addCustomerInfoUpdateListener(onUpdate);
        // 更新通知は「SDK がまだ一度も受け取っていない」間は流れてこないため、
        // 購読開始時点の値だけは自分で取りに行く。
        unawaited(_emitCurrent(controller));
      },
      onCancel: () => Purchases.removeCustomerInfoUpdateListener(onUpdate),
    );

    return controller.stream;
  }

  Future<void> _emitCurrent(StreamController<bool> controller) async {
    try {
      final info = await Purchases.getCustomerInfo();
      if (!controller.isClosed) controller.add(_isProActive(info));
    } on Object catch (error) {
      // 圏外での初回起動くらいでしか起きない(SDK が端末にキャッシュを持つ)。
      // 取れなければ広告が出るだけなので、課金の失敗で本体は止めない。
      purchaseLog('購入状態を取得できませんでした: $error');
    }
  }

  @override
  Future<String?> fetchPriceText() async {
    try {
      final package = await _fetchLifetimePackage();
      return package?.storeProduct.priceString;
    } on Object catch (error) {
      purchaseLog('価格を取得できませんでした: $error');
      return null;
    }
  }

  @override
  Future<PurchaseOutcome> purchase() async {
    try {
      final package = await _fetchLifetimePackage();
      if (package == null) {
        purchaseLog('買い切りの商品が offering に見つかりません');
        return PurchaseOutcome.failed;
      }
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return _isProActive(result.customerInfo)
          ? PurchaseOutcome.purchased
          : PurchaseOutcome.failed;
    } on PlatformException catch (error) {
      // ダイアログを閉じただけの「キャンセル」は失敗として扱わない。
      final code = PurchasesErrorHelper.getErrorCode(error);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        purchaseLog('購入がキャンセルされました');
        return PurchaseOutcome.cancelled;
      }
      purchaseLog('購入に失敗しました: $code');
      return PurchaseOutcome.failed;
    } on Object catch (error) {
      purchaseLog('購入に失敗しました: $error');
      return PurchaseOutcome.failed;
    }
  }

  @override
  Future<bool> restore() async {
    final info = await Purchases.restorePurchases();
    return _isProActive(info);
  }

  /// 買い切り商品は offering の Lifetime パッケージに紐付ける。
  Future<Package?> _fetchLifetimePackage() async {
    final offerings = await Purchases.getOfferings();
    return offerings.current?.lifetime;
  }

  bool _isProActive(CustomerInfo info) =>
      info.entitlements.all[PurchaseConfig.entitlementId]?.isActive ?? false;
}

/// 課金の実装。テストではフェイクに差し替える。
@Riverpod(keepAlive: true)
PurchasesClient purchasesClient(Ref ref) => const RevenueCatPurchasesClient();
