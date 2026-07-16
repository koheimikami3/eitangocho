/// クイズの出題方向。表面に何を出すかを決める(既定は英語 → 日本語)。
enum QuizDirection {
  enToJa('英語 → 日本語'),
  jaToEn('日本語 → 英語');

  const QuizDirection(this.label);

  /// 設定画面の表示用ラベル
  final String label;
}
