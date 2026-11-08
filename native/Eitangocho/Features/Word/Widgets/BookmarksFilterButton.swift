import SwiftUI

/// macOS 版の全単語のブックマークの絞り込み(ツールバーの並び替えのボタンの左。iOS の MobileBookmarksFilterButton と同じ役割)。
///
/// 文字を付けず 🔖 だけの丸にし(iOS と同じ)、何のボタンかはヒントと読み上げで伝える。高さは並び替えのボタンと揃える。
/// 切っているときは線だけの控えめな形にし、入れるとアクセント色で塗って絞り込み中だと分かるようにする。
struct BookmarksFilterButton: View {
  let shell: MainShellModel

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @State private var isHovered = false

  /// 丸の直径(並び替えのボタンの高さと同じ)。
  private static let diameter: CGFloat = 32

  var body: some View {
    let isOn = shell.bookmarksOnly
    BookmarkIcon(filled: isOn, color: isOn ? Color.white : colors.textAlpha(isHovered ? 75 : 55), height: px(13))
      .frame(width: px(Self.diameter), height: px(Self.diameter))
      .background {
        if isOn { Circle().fill(isHovered ? colors.accentHover : colors.accent) }
      }
      .overlay(Circle().strokeBorder(isOn ? Color.clear : colors.borderAlpha(isHovered ? 30 : 18), lineWidth: px(1)))
      .hoverTap($isHovered, in: Circle()) { shell.setBookmarksOnly(!isOn) }
      #if os(macOS)
        .pointerStyle(.link)
      #endif
      .help(Text(.bookmarksFilter))
      .accessibilityLabel(Text(.bookmarksFilter))
      .accessibilityAddTraits(isOn ? .isSelected : [])
  }
}
