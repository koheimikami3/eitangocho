#if os(iOS)
  import SwiftUI

  /// iOS 版のお気に入りの ★(学習中のカードの下の帯・全単語の行で、🔊 の左に置く)。
  ///
  /// 付いていればテーマカラーで塗った ★、無ければ薄い線の ☆。🔊 のような丸い地は付けない
  /// (並んだときに主役の 🔊 と同じ重さに見えないように)。押すと弾む。
  /// タップ領域は 🔊 と同じ 44pt 幅 × 30pt 高(カードの帯が間延びしないよう、高さは広げない)。
  struct MobileFavoriteButton: View {
    let isFavorite: Bool
    let onToggle: (Bool) -> Void

    @Environment(\.palette) private var palette

    private static let iconSize: CGFloat = 18

    var body: some View {
      MobilePressable(action: { onToggle(!isFavorite) }) {
        Image(systemName: isFavorite ? "star.fill" : "star")
          .font(.system(size: Self.iconSize, weight: .medium))
          .foregroundStyle(isFavorite ? palette.accent : palette.textAlpha(30))
          .symbolEffect(.bounce, value: isFavorite)
          .frame(width: MobilePronunciationButton.minTapTarget, height: MobilePronunciationButton.circleDiameter)
          .contentShape(Rectangle())
      }
      .accessibilityLabel(Text(isFavorite ? .removeFromFavorites : .addToFavorites))
    }
  }
#endif
