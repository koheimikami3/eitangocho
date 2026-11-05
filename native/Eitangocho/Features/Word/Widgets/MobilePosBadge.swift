#if os(iOS)
  import EitangochoData
  import SwiftUI

  /// iOS 版の品詞バッジ(ピル。Flutter 版の MobilePosBadge)。品詞ごとに 1 枚ずつ、その品詞の色で並べる
  /// (収まらない分はピルの形のまま次の行に回す。macOS 版の PosBadge と同じ理由)。
  struct MobilePosBadge: View {
    let partsOfSpeech: [PartOfSpeech]

    @Environment(\.palette) private var palette

    var body: some View {
      FlowLayout(spacing: 4, runSpacing: 4) {
        ForEach(partsOfSpeech.isEmpty ? [.other] : partsOfSpeech.inChipOrder, id: \.self) { pos in
          let (background, foreground) = pos.badgeColors(palette)
          AppText(pos.label, style: AppTextStyle(size: 10, weight: .w600))
            .foregroundStyle(foreground)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(Capsule().fill(background))
        }
      }
    }
  }
#endif
