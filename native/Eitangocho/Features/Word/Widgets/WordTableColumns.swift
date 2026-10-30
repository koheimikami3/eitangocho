import CoreGraphics

/// 全単語の表の列幅(Flutter 版の WordTableHeader / WordTableRow と同じ)。
/// 訳と例文の列は、固定の列と間隔を除いた残りを 2 : 3 で分ける。
struct WordTableColumns {
  static let learned: CGFloat = 64
  static let word: CGFloat = 140
  static let ipa: CGFloat = 130
  static let partOfSpeech: CGFloat = 100
  static let pronunciation: CGFloat = 56
  static let gap: CGFloat = 12
  static let horizontalPadding: CGFloat = 20

  let meaning: CGFloat
  let example: CGFloat

  /// `tableWidth` は素の値(倍率を掛ける前)。
  init(tableWidth: CGFloat) {
    let fixed = Self.learned + Self.word + Self.ipa + Self.partOfSpeech + Self.pronunciation
    let flexible = max(tableWidth - Self.horizontalPadding * 2 - fixed - Self.gap * 6, 0)
    meaning = flexible * 2 / 5
    example = flexible * 3 / 5
  }
}
