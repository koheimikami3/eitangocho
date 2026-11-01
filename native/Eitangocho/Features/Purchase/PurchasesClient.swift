import Foundation
import OSLog

#if os(iOS)
  import RevenueCat
#endif

/// 購入処理の結果。
enum PurchaseOutcome {
  /// entitlement が有効になった。
  case purchased
  /// ユーザーが App Store のダイアログを閉じた。無音で戻る。
  case cancelled
  /// 失敗した。メッセージを出す。
  case failed
}

/// RevenueCat SDK の呼び出しを閉じ込める抽象(Flutter 版の PurchasesClient)。
///
/// SDK の型が `PurchaseModel` より上に漏れないようにする。テストではフェイクに差し替える
/// (テストは macOS で動き、macOS には SDK をリンクしていないため)。
protocol PurchasesClient {
  /// 課金を扱える環境か。false なら他の操作は呼ばれない。
  var isAvailable: Bool { get }

  /// SDK を初期化する。他の操作はこれを待ってから呼ぶ。
  func configure() async throws

  /// Pro が解禁されているか。購読を始めた時点の値と、以後の変化が流れる。
  func proUnlockedUpdates() -> AsyncStream<Bool>

  /// 買い切り商品の表示価格(ローカライズ済み)。取れなければ nil。
  func fetchPriceText() async -> String?

  /// 買い切り商品を購入する。
  func purchase() async -> PurchaseOutcome

  /// 過去の購入を復元する。Pro になったかを返す。
  func restore() async throws -> Bool
}

/// 課金まわりのログ。課金は「買えない」が正常系(キー未設定・商品が未承認・Sandbox 未ログイン)と
/// 区別がつかず、動作確認も実機でしかできない。失敗を黙って握ると原因を追う手段が無くなるため、
/// 経路の要所で出す(Flutter 版の purchaseLog)。
let purchaseLogger = Logger(subsystem: "com.kohei.mikami.eitangocho", category: "purchase")

/// 課金を扱えない環境(macOS)の実装。何も呼ばれない。
struct UnavailablePurchasesClient: PurchasesClient {
  var isAvailable: Bool { false }
  func configure() async throws {}
  func proUnlockedUpdates() -> AsyncStream<Bool> { AsyncStream { $0.finish() } }
  func fetchPriceText() async -> String? { nil }
  func purchase() async -> PurchaseOutcome { .failed }
  func restore() async throws -> Bool { false }
}

#if os(iOS)
  /// RevenueCat による実装。
  struct RevenueCatPurchasesClient: PurchasesClient {
    var isAvailable: Bool { PurchaseConfig.isAvailable }

    func configure() async throws {
      #if DEBUG
        Purchases.logLevel = .debug
      #else
        Purchases.logLevel = .warn
      #endif
      Purchases.configure(withAPIKey: PurchaseConfig.appleApiKey)
    }

    /// 購入・復元だけでなく、返金・別端末での購入・失効もここに流れる。
    ///
    /// 購入導線を通ったときにしか状態を見ない作りにすると、他端末で買ったユーザーにいつまでも
    /// 広告が出る。SDK の更新通知を張り続けて追従する。
    func proUnlockedUpdates() -> AsyncStream<Bool> {
      AsyncStream { continuation in
        let task = Task {
          // 更新通知は「SDK がまだ一度も受け取っていない」間は流れてこないため、
          // 購読開始時点の値だけは自分で取りに行く(Flutter 版と同じ)。
          do {
            continuation.yield(Self.isProActive(try await Purchases.shared.customerInfo()))
          } catch {
            // 圏外での初回起動くらいでしか起きない(SDK が端末にキャッシュを持つ)。
            // 取れなければ広告が出るだけなので、課金の失敗で本体は止めない。
            purchaseLogger.error("購入状態を取得できませんでした: \(String(describing: error), privacy: .public)")
          }
          for await info in Purchases.shared.customerInfoStream {
            continuation.yield(Self.isProActive(info))
          }
          continuation.finish()
        }
        continuation.onTermination = { _ in task.cancel() }
      }
    }

    func fetchPriceText() async -> String? {
      do {
        return try await Self.lifetimePackage()?.storeProduct.localizedPriceString
      } catch {
        purchaseLogger.error("価格を取得できませんでした: \(String(describing: error), privacy: .public)")
        return nil
      }
    }

    func purchase() async -> PurchaseOutcome {
      do {
        guard let package = try await Self.lifetimePackage() else {
          purchaseLogger.error("買い切りの商品が offering に見つかりません")
          return .failed
        }
        let result = try await Purchases.shared.purchase(package: package)
        if result.userCancelled {
          purchaseLogger.info("購入がキャンセルされました")
          return .cancelled
        }
        return Self.isProActive(result.customerInfo) ? .purchased : .failed
      } catch let error as RevenueCat.ErrorCode where error == .purchaseCancelledError {
        // ダイアログを閉じただけの「キャンセル」は失敗として扱わない。
        purchaseLogger.info("購入がキャンセルされました")
        return .cancelled
      } catch {
        purchaseLogger.error("購入に失敗しました: \(String(describing: error), privacy: .public)")
        return .failed
      }
    }

    func restore() async throws -> Bool {
      Self.isProActive(try await Purchases.shared.restorePurchases())
    }

    /// 買い切り商品は offering(`default` = current)の Lifetime パッケージ(`$rc_lifetime`)に紐付ける。
    private static func lifetimePackage() async throws -> Package? {
      try await Purchases.shared.offerings().current?.lifetime
    }

    private static func isProActive(_ info: CustomerInfo) -> Bool {
      info.entitlements.all[PurchaseConfig.entitlementId]?.isActive ?? false
    }
  }
#endif
