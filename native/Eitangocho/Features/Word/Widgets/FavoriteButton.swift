import SwiftUI

/// macOS 版のお気に入りの ★(学習中のカードの下の帯・全単語の表で、🔊 の左に置く。iOS の MobileFavoriteButton と同じ役割)。
///
/// 付いていればアクセント色で塗った ★、無ければ薄い線の ☆。🔊 のような丸い地は付けない
/// (並んだときに主役の 🔊 と同じ重さに見えないように)。ホバーで濃くし、押すと弾む。
struct FavoriteButton: View {
  let isFavorite: Bool
  let onToggle: (Bool) -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @State private var isHovered = false

  /// 押せる範囲の一辺(表の 🔊 の円と同じ)。
  static let size: CGFloat = 28

  var body: some View {
    let label: LocalizedStringResource = isFavorite ? .removeFromFavorites : .addToFavorites
    Image(systemName: isFavorite ? "star.fill" : "star")
      .font(.system(size: px(15), weight: .medium))
      .foregroundStyle(isFavorite ? colors.accent : colors.textAlpha(isHovered ? 55 : 30))
      .symbolEffect(.bounce, value: isFavorite)
      .frame(width: px(Self.size), height: px(Self.size))
      .hoverTap($isHovered, in: Rectangle()) { onToggle(!isFavorite) }
      #if os(macOS)
        .pointerStyle(.link)
      #endif
      .help(Text(label))
      .accessibilityLabel(Text(label))
  }
}
