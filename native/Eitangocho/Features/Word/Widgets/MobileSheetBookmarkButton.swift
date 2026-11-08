#if os(iOS)
  import SwiftUI

  /// 登録・編集シートの見出しの 🔖(右上の「登録」「保存」の左。左上の ✕ と同じガラスの丸)。
  ///
  /// 学習中のカードには置かない(覚えるための面に操作を増やさない。2026-11-08 のユーザー判断)。
  /// カードからブックマークするときは、カードを押して編集シートを開き、ここで付ける。
  struct MobileSheetBookmarkButton: View {
    let isBookmarked: Bool
    let onToggle: (Bool) -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      let label: LocalizedStringResource = isBookmarked ? .removeBookmark : .addBookmark
      MobileGlassCircleButton(
        accessibilityLabel: String(localized: label),
        customIcon: AnyView(
          BookmarkIcon(filled: isBookmarked, color: isBookmarked ? palette.accent : palette.text, height: 17))
      ) {
        onToggle(!isBookmarked)
      }
    }
  }
#endif
