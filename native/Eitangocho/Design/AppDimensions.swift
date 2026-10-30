import CoreGraphics

/// 寸法定数。UI レイアウトの正基準となる値(Flutter 版の `lib/constants/app_dimensions.dart` と同じ)。
///
/// 画面には素の値を書き、表示倍率(uiScale)は `@Environment(\.uiScale)` の
/// `px(_:)` で掛ける。iOS の値は Phase 6 で使う。
nonisolated enum AppDimensions {
  static let sidebarWidth: CGFloat = 212
  static let toolbarHeight: CGFloat = 52
  static let contentPadding: CGFloat = 20
  /// 登録フォーム・編集モーダルの幅
  static let formWidth: CGFloat = 560
  /// カードグリッド用
  static let cardMinWidth: CGFloat = 260
  static let gridGap: CGFloat = 14

  /// 全単語テーブルの最小幅。これより狭いビューでは横スクロールになる。
  static let tableMinWidth: CGFloat = 880

  /// UI 全体の拡大率(ブラウザのズーム相当)の既定値。素の値をそのまま使うと
  /// 実機では全体的に小さく感じる、というユーザー判断による。
  /// 実際の値は設定(SettingsStore.uiScale)で変えられ、これは未設定時のフォールバック。
  static let defaultUiScale: Double = 1.5

  /// 設定で選べる拡大率の範囲(0.1 刻み)
  static let minUiScale: Double = 1.0
  static let maxUiScale: Double = 2.0

  /// iOS のコンテンツ最大幅(デザインの iPhone フレーム幅 402pt)。
  static let mobileContentMaxWidth: CGFloat = 402

  /// iOS の画面外周パディング
  static let mobilePadding: CGFloat = 16

  /// iOS のカード(単語カード・設定のセクションなど)の角丸。
  static let mobileCardRadius: CGFloat = 8

  /// iOS の学習中カードグリッドの間隔
  static let mobileGridGap: CGFloat = 12

  /// iOS の入力カーソル幅
  static let mobileCursorWidth: CGFloat = 1.5
}
