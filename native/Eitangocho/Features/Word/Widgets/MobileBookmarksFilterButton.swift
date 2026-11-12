#if os(iOS)
  import SwiftUI

  /// iOS 版の全単語のブックマークの絞り込み(並び替えの行の左。🔖 だけの丸いボタン)。
  ///
  /// 文字を付けず 🔖 だけにする(よくある見せ方で、行の幅を件数や並び替えに回せるため。2026-11-08 のユーザー判断)。
  /// ヘッダ右上の 🔍・⚙ と同じガラスの丸にする(並び替えのガラスのカプセルと揃える。試作)。
  /// 入れるとアクセント色を付けたガラス(右下の ＋ と同じ)にし、絞り込み中だと分かるようにする。読み上げでは「ブックマーク」と名乗る。
  struct MobileBookmarksFilterButton: View {
    let shell: MainShellModel

    @Environment(\.palette) private var palette

    /// 丸の直径。並び替えのカプセルと同じ高さにする。
    static let diameter: CGFloat = 36

    var body: some View {
      let isOn = shell.bookmarksOnly
      MobileGlassCircleButton(
        accessibilityLabel: String(localized: .bookmarksFilter), size: Self.diameter, prominent: isOn,
        customIcon: AnyView(BookmarkIcon(filled: isOn, color: isOn ? Color.white : palette.text, height: 16))
      ) {
        shell.setBookmarksOnly(!isOn)
      }
      .accessibilityAddTraits(isOn ? .isSelected : [])
    }
  }
#endif
