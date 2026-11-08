import SwiftUI

/// macOS 版の全単語のお気に入りの絞り込み(ツールバーの並び替えのボタンの左。iOS の MobileFavoritesFilterButton と同じ役割)。
///
/// 切っているときは線だけの控えめな形にし、入れるとアクセント色で塗って絞り込み中だと分かるようにする
/// (常に色の付いた並び替えのボタンと並んでも、オン / オフが見分けられるように)。
struct FavoritesFilterButton: View {
  let shell: MainShellModel

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @State private var isHovered = false

  var body: some View {
    let isOn = shell.favoritesOnly
    HStack(spacing: px(5)) {
      Image(systemName: isOn ? "star.fill" : "star")
        .font(.system(size: px(12), weight: .semibold))
      AppText(.favoritesFilter, style: AppTextStyle(size: 13, weight: .w600))
        .lineLimit(1)
    }
    .foregroundStyle(isOn ? Color.white : colors.textAlpha(isHovered ? 75 : 60))
    // 並び替えのボタンと同じ高さにする(縁の 1 を含む)。
    .padding(.horizontal, px(12 + 1))
    .padding(.vertical, px(7 + 1))
    .background {
      if isOn { Capsule().fill(isHovered ? colors.accentHover : colors.accent) }
    }
    .overlay(Capsule().strokeBorder(isOn ? Color.clear : colors.borderAlpha(isHovered ? 30 : 18), lineWidth: px(1)))
    .fixedSize()
    .hoverTap($isHovered, in: Capsule()) { shell.setFavoritesOnly(!isOn) }
    #if os(macOS)
      .pointerStyle(.link)
    #endif
    .accessibilityAddTraits(isOn ? .isSelected : [])
  }
}
