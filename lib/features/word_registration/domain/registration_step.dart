/// 単語登録の 2 ステップフロー(プロトタイプの addStep に対応)。
enum RegistrationStep {
  /// ステップ 1: 英単語の入力(自動入力 or 手動へスキップ)
  input,

  /// 辞書データ取得中
  loading,

  /// ステップ 2: 確認・修正フォーム
  form,
}
