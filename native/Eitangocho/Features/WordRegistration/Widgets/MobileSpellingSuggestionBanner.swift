#if os(iOS)
  import SwiftUI

  /// 綴りの誤りとみられる入力に、正しい綴りの候補を出す帯(iOS の登録シート用)。
  /// 見た目は登録シートの警告の帯にそろえ、候補は押せる語にする。押すとその語で自動入力をやり直す。
  struct MobileSpellingSuggestionBanner: View {
    let suggestions: [String]
    let onSelect: (String) -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      let shape = RoundedRectangle(cornerRadius: 12)
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
