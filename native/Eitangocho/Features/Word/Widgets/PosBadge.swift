import EitangochoData
import SwiftUI

/// 品詞バッジ(ピル)。品詞ごとに 1 枚ずつ、その品詞の色で並べる(Flutter 版の PosBadge)。
///
/// 全品詞を 1 枚に連結していた頃は、表の狭い列で品詞が多いと 1 枚の中で
/// 文字が折り返して塊になっていた。1 枚ずつなら、収まらない分はピルの形のまま次の行に回る。
struct PosBadge: View {
  let partsOfSpeech: [PartOfSpeech]

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    FlowLayout(spacing: px(4), runSpacing: px(4)) {
      ForEach(partsOfSpeech.isEmpty ? [.other] : partsOfSpeech, id: \.self) { pos in
        let (background, foreground) = pos.badgeColors(colors)
        AppText(pos.label, style: AppTextStyle(size: 11, weight: .w600))
          .foregroundStyle(foreground)
          .padding(.horizontal, px(8))
          .padding(.vertical, px(2))
          .background(Capsule().fill(background))
      }
    }
  }
}
