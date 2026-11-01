import Foundation

/// 縦に伸びる入力欄で、Return キーで入った改行を見分ける(iOS の MobileLabeledField が使う)。
///
/// SwiftUI の縦に伸びる TextField は Return で改行を入れるだけで、キーが押されたことを知らせない。
/// そこで変更の前後を比べ、変わった所に入った文字が改行 1 つで終わるときだけ Return とみなす
/// (自動修正が単語を直しながら改行を入れることがあるため、改行だけの挿入に限らない)。
/// 改行を含む文の貼り付けと、もとから改行を含む文の編集は入力どおりに残す(Flutter 版の TextInputAction.done と同じ)。
nonisolated enum ReturnKeyInput {
  /// `new` が `old` に Return を押した結果なら、Return が無かったときの文字を返す。そうでなければ nil。
  ///
  /// - 改行だけが入ったとき(選択していた文字を改行で置き換えたときも)は、押す前の `old` に戻す
  ///   (Flutter 版の「完了」は文字を変えないので、選択していた文字も消さない)
  /// - 自動修正が単語を直しながら改行を入れたとき(文字数が減る直しも)は、直した単語を残して改行だけを取り除く
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
    if inserted.count == 1 { return old }
    var result = newChars
    result.remove(at: insertedEnd - 1)
    return String(result)
  }
}
