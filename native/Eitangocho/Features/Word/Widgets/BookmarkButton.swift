import SwiftUI

/// macOS 版のブックマークの 🔖(全単語の表で、🔊 の左に置く。iOS の MobileBookmarkButton と同じ役割)。
///
/// 付いていればアクセント色で塗った 🔖、無ければ薄い線の 🔖。🔊 のような丸い地は付けない
/// (並んだときに主役の 🔊 と同じ重さに見えないように)。大きさも 🔊 の絵柄と同じくらいにして、🔊 より目立たせない。
/// ホバーで濃くする。
struct BookmarkButton: View {
  let isBookmarked: Bool
  /// 絵柄の高さ。表の行は 🔊 と釣り合う既定の値、編集ダイアログは見出しの横で小さく見えないよう大きくする。
  var iconHeight: CGFloat = 18
  let onToggle: (Bool) -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @State private var isHovered = false

  /// 押せる範囲の一辺(表の 🔊 の円と同じ)。
  static let size: CGFloat = 28

  var body: some View {
    let label: LocalizedStringResource = isBookmarked ? .removeBookmark : .addBookmark
    BookmarkIcon(
      filled: isBookmarked, color: isBookmarked ? colors.accent : colors.textAlpha(isHovered ? 50 : 30), height: px(iconHeight))
      .frame(width: px(Self.size), height: px(Self.size))
      .hoverTap($isHovered, in: Rectangle()) { onToggle(!isBookmarked) }
      #if os(macOS)
        .pointerStyle(.link)
      #endif
      .help(Text(label))
      .accessibilityLabel(Text(label))
  }
}
