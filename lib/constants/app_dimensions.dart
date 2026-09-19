/// 寸法定数。UI レイアウトの正基準となる値(当初は HTML プロトタイプから抽出したが、
/// プロトタイプ廃止に伴い、これらの値自体が正基準)。
abstract final class AppDimensions {
  static const sidebarWidth = 212.0;
  static const toolbarHeight = 52.0;
  static const contentPadding = 20.0;
  static const formWidth = 560.0; // 登録フォーム・編集モーダルの幅
  static const cardMinWidth = 260.0; // カードグリッド用
  static const gridGap = 14.0;

  /// 全単語テーブルの最小幅。これより狭いビューでは横スクロールになる
  /// (min-width:880px + overflow:auto 相当)
  static const tableMinWidth = 880.0;

  /// UI 全体の拡大率(ブラウザのズーム相当)の既定値。素の px 値を
  /// そのまま使うと実機では全体的に小さく感じる、というユーザー判断による。
  /// 実際の値は設定画面のスライダーで変更でき(SettingsState.uiScale)、
  /// これは未設定時のフォールバック。
  static const defaultUiScale = 1.5;

  /// 設定スライダーで選べる拡大率の範囲(0.1 刻み)
  static const minUiScale = 1.0;
  static const maxUiScale = 2.0;

  /// iOS のコンテンツ最大幅。iPad ではこの幅で中央に寄せ、iPhone 相当の
  /// 縦長レイアウトをそのまま使う(デザインの iPhone フレーム幅 402pt)。
  /// iPad 専用レイアウトを作る際はこの制約ごと差し替える。
  static const mobileContentMaxWidth = 402.0;

  /// iOS の画面外周パディング(デザインの padding:16px)
  static const mobilePadding = 16.0;

  /// iOS のカード(単語カード・設定のセクションなど)の角丸。
  /// 1.6.0 の刷新案 A で 12 → 13 に上げた(浮いた面のクイズカードは 16 のまま)。
  static const mobileCardRadius = 13.0;

  /// iOS の学習中カードグリッドの間隔
  /// (列数は設定 LearningCardLayout が持つ)
  static const mobileGridGap = 12.0;

  /// iOS の入力カーソル幅。Material の既定 2.0 は細いフォームの中で太く見えるため、
  /// UIKit の見え方に近い 1.5 に落とす(色はアクセント色を使う)。
  static const mobileCursorWidth = 1.5;
}
