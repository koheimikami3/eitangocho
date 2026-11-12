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

  /// 課金を扱えるか(SDK キーが設定済みか)。
  ///
  /// macOS でも同じ entitlement を使う。Bundle ID が同じ(Universal Purchase)なので、どちらの OS で買っても
  /// 両方で Pro になる。macOS には広告が無く、テーマカラーとクイズの選択肢を解放する(2.18.0 から)。
  static var isAvailable: Bool { !appleApiKey.isEmpty }
}
