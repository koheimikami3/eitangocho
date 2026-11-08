import SwiftUI

/// 辞書の注意と、綴りの誤りとみられる入力への正しい綴りの候補をまとめて出す帯
/// (「辞書に見つかりませんでした。…」の下に「もしかして: independent」)。
///
/// 見た目は DictionaryWarningBanner にそろえ、候補は押せる語にする。押すとその語で自動入力をやり直す。
/// 注意と候補は同じ原因(辞書に当たらない)の話なので、帯を 2 つ重ねず 1 つにまとめる。
/// 注意が無く候補だけのときは、候補の行だけを出す。
struct SpellingSuggestionBanner: View {
  let message: String?
  let suggestions: [String]
  let onSelect: (String) -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: px(8))
    VStack(alignment: .leading, spacing: px(6)) {
      if let message {
        AppText(message, style: AppTextStyle(size: 13))
      }
      HStack(spacing: px(10)) {
        AppText(.noticeSpellingSuggestion, style: AppTextStyle(size: 13))
        ForEach(suggestions, id: \.self) { suggestion in
          SuggestionLink(word: suggestion) { onSelect(suggestion) }
        }
      }
    }
    .foregroundStyle(colors.warningBannerForeground)
    .padding(.horizontal, px(14 + 1))
    .padding(.vertical, px(10 + 1))
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(shape.fill(colors.warningBannerBackground))
    .overlay(shape.strokeBorder(colors.warningBannerBorder, lineWidth: px(1)))
  }

  /// 押せる候補の語(下線付き。ホバーで少し薄くして押せることを示す)。
  private struct SuggestionLink: View {
    let word: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
      AppText(word, style: AppTextStyle(size: 13, weight: .w600))
        .underline()
        .opacity(isHovered ? 0.7 : 1)
        .hoverTap($isHovered, in: Rectangle(), action: action)
    }
  }
}
