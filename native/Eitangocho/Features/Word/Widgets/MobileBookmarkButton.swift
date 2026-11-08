#if os(iOS)
  import SwiftUI

  /// iOS 版のブックマークの 🔖(全単語の行で、🔊 の左に置く)。
  ///
  /// 付いていればテーマカラーで塗った 🔖、無ければ薄い線の 🔖。🔊 のような丸い地は付けない
  /// (並んだときに主役の 🔊 と同じ重さに見えないように)。大きさは 🔊 の絵柄より少し大きい程度に留める。押すと塗りが切り替わる。
  /// タップ領域は 30pt 四方で、絵柄はその中央に置く。🔊 と同じ 44pt 幅にすると、全単語の行で訳に回る幅が削られて早く省略されるため。
  /// 🔊 とはタップ領域を重ねない(重ねると 🔖 の右半分を押しても 🔊 が鳴る。2026-11-08 のユーザーの指摘)。
  /// 🔊 の側も行では丸の左の余白を詰め(`MobilePronunciationButton.iconTapWidth`)、境目が絵柄の間の余白に来るようにする。
  struct MobileBookmarkButton: View {
    let isBookmarked: Bool
    let onToggle: (Bool) -> Void

    @Environment(\.palette) private var palette

    private static let iconSize: CGFloat = 17
    private static let tapWidth: CGFloat = 30

    var body: some View {
      let label: LocalizedStringResource = isBookmarked ? .removeBookmark : .addBookmark
      MobilePressable(action: { onToggle(!isBookmarked) }) {
        BookmarkIcon(
          filled: isBookmarked, color: isBookmarked ? palette.accent : palette.textAlpha(30), height: Self.iconSize)
          .frame(width: Self.tapWidth, height: MobilePronunciationButton.circleDiameter)
          .contentShape(Rectangle())
      }
      .accessibilityLabel(Text(label))
    }
  }
#endif
