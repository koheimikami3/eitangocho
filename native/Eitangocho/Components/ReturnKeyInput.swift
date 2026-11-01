import Foundation

/// 縦に伸びる入力欄で、Return キーで入った改行を見分ける(iOS の MobileLabeledField が使う)。
///
/// SwiftUI の縦に伸びる TextField は Return で改行を入れるだけで、キーが押されたことを知らせない。
/// そこで変更の前後を比べ、変わった所に入った文字が改行 1 つで終わるときだけ Return とみなす
/// (自動修正が単語を直しながら改行を入れることがあるため、改行だけの挿入に限らない)。
/// 改行を含む文の貼り付けと、もとから改行を含む文の編集は入力どおりに残す(Flutter 版の TextInputAction.done と同じ)。
nonisolated enum ReturnKeyInput {
  /// `new` が `old` に Return を押した結果なら、入った改行だけを取り除いた文字を返す。そうでなければ nil。
  ///
  /// 前後の文字だけでは「選択して Return」と「改行で終わる文の貼り付け」・「自動修正と Return」を区別できない。
  /// 押す前の `old` に戻すと貼り付けた文や自動修正を巻き戻してしまうので、常に改行だけを取り除く
  /// (選択して Return を押したときは、選択していた文字が消える)。改行で終わる文を選択して Return を押したときは
  /// 改行が残る(どちらも滅多に起きないので、入力欄を作り替えてまでは直さない)。
  static func removingReturn(old: String, new: String) -> String? {
    let oldChars = Array(old)
    let newChars = Array(new)
    // 前後で同じ部分を除いた、新しく入った部分(newChars[prefix..<insertedEnd])を求める。
    let prefix = zip(oldChars, newChars).prefix { $0 == $1 }.count
    let suffix = zip(oldChars.reversed(), newChars.reversed()).prefix { $0 == $1 }.count
    let sharedSuffix = min(suffix, oldChars.count - prefix, newChars.count - prefix)
    let insertedEnd = newChars.count - sharedSuffix
    let inserted = newChars[prefix..<insertedEnd]
    guard inserted.last == "\n", inserted.count(where: { $0 == "\n" }) == 1 else { return nil }
    var result = newChars
    result.remove(at: insertedEnd - 1)
    return String(result)
  }
}
