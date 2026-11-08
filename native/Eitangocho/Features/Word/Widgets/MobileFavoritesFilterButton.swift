#if os(iOS)
  import SwiftUI

  /// iOS 版の全単語のお気に入りの絞り込み(並び替えの行の左。並び替えのボタンと同じ大きさのピル形)。
  ///
  /// 切っているときは線だけの控えめな形にし、入れると主ボタンと同じ地(白い文字が読める濃さ)で塗って
  /// 絞り込み中だと分かるようにする(常に色の付いた並び替えのボタンと並んでも、オン / オフが見分けられるように)。
  struct MobileFavoritesFilterButton: View {
    let shell: MainShellModel

    @Environment(\.palette) private var palette

    var body: some View {
      let isOn = shell.favoritesOnly
      MobilePressable(action: { shell.setFavoritesOnly(!isOn) }) {
        HStack(spacing: 5) {
          Image(systemName: isOn ? "star.fill" : "star")
            .font(.system(size: 12, weight: .semibold))
          AppText(.favoritesFilter, style: AppTextStyle(size: 12, weight: .w700))
        }
        .foregroundStyle(isOn ? Color.white : palette.textAlpha(60))
        .padding(.horizontal, 13)
        .padding(.vertical, 6)
        .frame(minHeight: 32)
        .background {
          if isOn { Capsule().fill(palette.buttonFill) }
        }
        .overlay(Capsule().strokeBorder(isOn ? Color.clear : palette.borderAlpha(18), lineWidth: 1))
      }
      .accessibilityAddTraits(isOn ? .isSelected : [])
    }
  }
#endif
