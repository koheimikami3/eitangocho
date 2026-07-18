/// 寸法定数。値は docs/prototype/design/eitangocho.html から抽出したもの。
abstract final class AppDimensions {
  static const sidebarWidth = 212.0;
  static const toolbarHeight = 52.0;
  static const contentPadding = 20.0;
  static const formWidth = 560.0; // 登録フォーム・編集モーダルの幅
  static const cardMinWidth = 260.0; // Phase 2 のカードグリッド用
  static const gridGap = 14.0;

  /// 全単語テーブルの最小幅。これより狭いビューでは横スクロールになる
  /// (プロトタイプの min-width:880px + overflow:auto 準拠)
  static const tableMinWidth = 880.0;

  /// UI 全体の拡大率(ブラウザのズーム相当)の既定値。プロトタイプの CSS px 値を
  /// そのまま使うと実機では全体的に小さく感じる、というユーザー判断による。
  /// 実際の値は設定画面のスライダーで変更でき(SettingsState.uiScale)、
  /// これは未設定時のフォールバック。
  static const defaultUiScale = 1.5;

  /// 設定スライダーで選べる拡大率の範囲(0.1 刻み)
  static const minUiScale = 1.0;
  static const maxUiScale = 2.0;
}
