import Foundation

/// 登録単語数が一定を超えた人に、保存直後に 1 回だけ出す Pro の案内(ProPrompter)の条件。
///
/// 使い込んでいる人にだけ Pro の中身を見せるため、登録の保存直後(手が空いている瞬間)に絞る。
/// 毎回出すと登録の邪魔になるので、案内ごとに 1 回きりにする。
enum ProPromptConfig {
  /// 案内の番号。出した番号を UserDefaults に残し、これより古い番号しか残っていない人にだけ出す。
  ///
  /// **出し直すときはこの値を 1 つ上げる**(Pro の中身が増えたときなど)。上げた版に更新した人は、
  /// 前の案内を見ていても次の登録の後にもう 1 回だけ見る。
  static let campaign = 1

  /// 案内を出す登録単語数の下限。ちょうどこの数に限らず、超えている人にも次の登録で出す
  /// (この版より前から使っている人も対象にするため)。
  static let minWordCount = 30

  /// シートが閉じてから案内を出すまでの待ち時間(レビュー依頼の `ReviewConfig.promptDelay` と同じ)。
  static let promptDelay: Duration = .seconds(1)
}
