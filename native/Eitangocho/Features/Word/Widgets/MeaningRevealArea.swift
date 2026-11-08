import SwiftUI

/// カードの訳の隠し / 表示(Flutter 版の WordCard の _RevealArea)。
/// 未表示は破線のボタン、表示は入力欄と同じ地 + 枠の訳。
struct MeaningRevealArea: View {
  let meaning: String
  let revealed: Bool
  let showLabel: String
  let onToggle: () -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @State private var isHovered = false

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: px(7))
    Group {
      if revealed {
        AppText(meaning, style: AppTextStyle(size: 13))
          .foregroundStyle(colors.textPrimary)
          .padding(.horizontal, px(10 + 1))
          .padding(.vertical, px(8 + 1))
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(shape.fill(colors.inputFill))
          .overlay(shape.strokeBorder(colors.inputBorder, lineWidth: px(1)))
      } else {
        DottedBorderBox {
          AppText(showLabel, style: AppTextStyle(size: 12))
            .foregroundStyle(colors.textAlpha(40))
        }
      }
    }
    // ホバーは薄いグレーを重ねて示す。未表示・表示中で同じ色にする(切り替えても押せる場所の見え方が変わらないように)。
    .overlay(shape.fill(isHovered ? colors.textAlpha(3) : .clear).allowsHitTesting(false))
    // カードのクリック(編集)には伝えない。
    .hoverTap($isHovered, in: shape, action: onToggle)
  }
}
