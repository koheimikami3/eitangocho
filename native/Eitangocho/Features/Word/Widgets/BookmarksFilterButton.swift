import SwiftUI

/// macOS 版の全単語のブックマークの絞り込み(ツールバーの並び替えのボタンの左。iOS の MobileBookmarksFilterButton と同じ役割)。
///
/// 文字を付けず 🔖 だけの丸にし(iOS と同じ)、何のボタンかはヒントと読み上げで伝える。高さは並び替えのボタンと揃える。
/// 切っているときは控えめな形にし、入れるとアクセント色を付けて絞り込み中だと分かるようにする(地の描き方は Surface)。
struct BookmarksFilterButton: View {
  let shell: MainShellModel

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @State private var isHovered = false

  /// 丸の直径(並び替えのボタンの高さと同じ。macOS 26 以降はツールバーのガラスの部品の高さ)。
  private static var diameter: CGFloat {
    if #available(macOS 26, iOS 26, *) { AppDimensions.toolbarControlHeight } else { 32 }
  }

  var body: some View {
    let isOn = shell.bookmarksOnly
    BookmarkIcon(filled: isOn, color: isOn ? Color.white : colors.textAlpha(isHovered ? 75 : 55), height: px(16))
      .frame(width: px(Self.diameter), height: px(Self.diameter))
      .modifier(Surface(isOn: isOn, isHovered: isHovered))
      .hoverTap($isHovered, in: Circle()) { shell.setBookmarksOnly(!isOn) }
      #if os(macOS)
        .pointerStyle(.link)
      #endif
      .help(Text(.bookmarksFilter))
      .accessibilityLabel(Text(.bookmarksFilter))
      .accessibilityAddTraits(isOn ? .isSelected : [])
  }

  /// 丸の地。macOS 26 以降はツールバーのほかの部品と同じ Liquid Glass にし、入れているときはアクセント色を付ける。
  /// それより前は、切っているときは線だけ、入れているときはアクセント色の塗り。
  private struct Surface: ViewModifier {
    let isOn: Bool
    let isHovered: Bool

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    func body(content: Content) -> some View {
      if #available(macOS 26, iOS 26, *) {
        content.glassEffect(isOn ? .regular.tint(colors.accent).interactive() : .regular.interactive(), in: .circle)
      } else {
        content
          .background {
            if isOn { Circle().fill(isHovered ? colors.accentHover : colors.accent) }
          }
          .overlay(Circle().strokeBorder(isOn ? Color.clear : colors.borderAlpha(isHovered ? 30 : 18), lineWidth: px(1)))
      }
    }
  }
}
