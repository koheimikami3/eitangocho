#if os(iOS)
  import SwiftUI

  /// 辞書の注意と、綴りの誤りとみられる入力への正しい綴りの候補をまとめて出す帯(iOS の登録シート用)。
  ///
  /// 見た目は登録シートの警告の帯にそろえ、候補は押せる語にする。押すとその語で自動入力をやり直す。
  /// 注意と候補は同じ原因(辞書に当たらない)の話なので、帯を 2 つ重ねず 1 つにまとめる。
  /// 注意が無く候補だけのときは、候補の行だけを出す。
  struct MobileSpellingSuggestionBanner: View {
    let message: String?
    let suggestions: [String]
    let onSelect: (String) -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      let shape = RoundedRectangle(cornerRadius: 12)
      VStack(alignment: .leading, spacing: 6) {
        if let message {
          AppText(message, style: AppTextStyle(size: 13, height: 1.5))
        }
        HStack(spacing: 12) {
          AppText(.noticeSpellingSuggestion, style: AppTextStyle(size: 13, height: 1.5))
          ForEach(suggestions, id: \.self) { suggestion in
            Button { onSelect(suggestion) } label: {
              AppText(suggestion, style: AppTextStyle(size: 13, weight: .w600, height: 1.5))
                .underline()
            }
            .buttonStyle(.plain)
          }
        }
      }
      .foregroundStyle(palette.warningBannerForeground)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 14)
      .padding(.vertical, 11)
      .background(shape.fill(palette.warningBannerBackground))
      .overlay(shape.strokeBorder(palette.warningBannerBorder, lineWidth: 1))
      .appShadows([AppShadow(color: Color(argb: 0x0F10_1828), blurRadius: 2, y: 1)], in: shape, scale: 1)
    }
  }
#endif
