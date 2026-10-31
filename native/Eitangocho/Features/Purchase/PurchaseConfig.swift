import Foundation

/// RevenueCat の設定値(Flutter 版の PurchaseConfig と同じ値)。
///
/// 公開 SDK キーをコードに直書きするのは、AdMob の広告ユニット ID と同じ理由。
/// RevenueCat が発行する公開値で、秘匿する意味も設定画面から入力させる意味も無い
/// (購入の検証は RevenueCat が Apple のレシートに対して行う)。
enum PurchaseConfig {
  /// RevenueCat の公開 SDK キー(Apple 用。`appl_` で始まる)。
  ///
  /// **空なら SDK に一切触れない。** `AdUnitIds.hasAnyUnit` と同じ保険で、
  /// RevenueCat への登録が済む前でも「Pro の欄が出ないだけで動く」ビルドになる。
  static let appleApiKey = "appl_gHFKDdyYkYhLiZuKjSPjyIPFvLX"

  /// 「広告を非表示にする」の entitlement ID(RevenueCat のダッシュボードで作る)。
  static let entitlementId = "pro"

  /// 課金を扱えるか。
  ///
  /// iOS 限定なのは、macOS には広告が無く解禁するものが何も無いため(macOS には SDK もリンクしていない)。
  /// 将来 macOS にも Pro 機能を出すときは、Bundle ID が同じ = Universal Purchase なので同じ entitlement を
  /// そのまま使える。
  static var isAvailable: Bool {
    #if os(iOS)
      !appleApiKey.isEmpty
    #else
      false
    #endif
  }
}
