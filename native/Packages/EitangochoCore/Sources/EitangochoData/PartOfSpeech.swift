/// 品詞。DB には rawValue を CSV 連結した文字列で保存する(Flutter 版の
/// PartOfSpeechListConverter と同じ形式)。
///
/// 宣言順は選択チップの並び順になるため、辞書や学校文法で一般的な
/// 名詞 → 動詞 → 形容詞 → 副詞 の順に合わせている。保存は rawValue なので
/// 順を変えても既存データには影響しない。
public enum PartOfSpeech: String, CaseIterable, Sendable {
  case noun
  case verb
  case adjective
  case adverb
  case other

  /// 'verb,noun' 形式の CSV を品詞の並びにする。
  ///
  /// 知らないトークンは黙って捨てる(将来 case を削除しても、古いデータや
  /// 新しい版が書いた値で読み込みが失敗しないようにするための防御)。
  public static func decodeList(_ csv: String) -> [PartOfSpeech] {
    if csv.isEmpty { return [] }
    return csv.split(separator: ",", omittingEmptySubsequences: false)
      .compactMap { PartOfSpeech(rawValue: String($0)) }
  }

  /// 品詞の並びを 'verb,noun' 形式の CSV にする。
  public static func encodeList(_ list: [PartOfSpeech]) -> String {
    list.map(\.rawValue).joined(separator: ",")
  }
}

extension Set where Element == PartOfSpeech {
  /// 選択された品詞を保存順に並べる。
  ///
  /// `basedOn` にある品詞はその並びを保ち、新しく選ばれたものだけを宣言順で
  /// 後ろに足す。`basedOn` には自動取得の結果(辞書が返した順 = その語の
  /// 主用法が先頭)や、編集前の保存順を渡す。
  ///
  /// チップのタップ順をそのまま保存すると、付け外ししただけでその品詞が
  /// 末尾に回り、先頭の品詞で決まるバッジ色が変わってしまうため。
  public func ordered(basedOn: [PartOfSpeech]) -> [PartOfSpeech] {
    basedOn.filter(contains)
      + PartOfSpeech.allCases.filter { contains($0) && !basedOn.contains($0) }
  }
}
