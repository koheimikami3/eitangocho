#if os(iOS)
  import SwiftUI

  /// iOS 版の設定カード内で行と行の間に挟む 1px の区切り線(Flutter 版の MobileSettingsDivider)。
  /// 左右 14 はカード内の行のパディングと同じ(線を行のテキストに揃える)。
  struct MobileSettingsDivider: View {
    @Environment(\.palette) private var palette

    var body: some View {
      Rectangle()
        .fill(palette.rowLine)
        .frame(height: 1)
        .padding(.horizontal, 14)
    }
  }
#endif
