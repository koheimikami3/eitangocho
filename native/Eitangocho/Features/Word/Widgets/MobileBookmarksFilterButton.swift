#if os(iOS)
  import SwiftUI

  /// iOS 版の全単語のブックマークの絞り込み(並び替えの行の左。🔖 だけの丸いボタン)。
  ///
  /// 文字を付けず 🔖 だけにする(よくある見せ方で、行の幅を件数や並び替えに回せるため。2026-11-08 のユーザー判断)。
  /// 並び替えのボタンと中央で揃える。切っているときは線だけの控えめな形にし、入れると主ボタンと同じ地
  /// (白い絵柄が読める濃さ)で塗って、絞り込み中だと分かるようにする。読み上げでは「ブックマーク」と名乗る。
  struct MobileBookmarksFilterButton: View {
    let shell: MainShellModel

    @Environment(\.palette) private var palette

    /// 丸の直径。並び替えのボタン(高さ 32pt)より少し大きくする。丸は同じ高さのカプセルの横に置くと
    /// 面積が小さく、一回り小さく見えるため(2026-11-08 のユーザーの指摘)。
    private static let diameter: CGFloat = 36

    var body: some View {
      let isOn = shell.bookmarksOnly
      MobilePressable(action: { shell.setBookmarksOnly(!isOn) }) {
        BookmarkIcon(filled: isOn, color: isOn ? Color.white : palette.textAlpha(55), height: 16)
          .frame(width: Self.diameter, height: Self.diameter)
          .background {
            if isOn { Circle().fill(palette.buttonFill) }
          }
          .overlay(Circle().strokeBorder(isOn ? Color.clear : palette.borderAlpha(18), lineWidth: 1))
          // 丸は 32pt だが、押せる範囲は 44pt 四方に広げる(上下は行の余白に収まる)。
          .frame(width: MobilePronunciationButton.minTapTarget, height: MobilePronunciationButton.minTapTarget)
          .contentShape(Rectangle())
      }
      // 左の余白を揃える(押せる範囲を広げた分だけ、丸が右へずれないように)。
      .padding(.horizontal, -(MobilePronunciationButton.minTapTarget - Self.diameter) / 2)
      .accessibilityLabel(Text(.bookmarksFilter))
      .accessibilityAddTraits(isOn ? .isSelected : [])
    }
  }
#endif
