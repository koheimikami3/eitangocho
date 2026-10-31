#if os(macOS)
  import SwiftUI

  /// 設定のカードの中で行と行の間に挟む 1px の区切り線(Flutter 版の SettingsDivider)。
  ///
  /// カードのほか、カードに複数の行をまとめて渡す側(同期・書き出し)も同じ線を内側に持つ。
  struct SettingsDivider: View {
    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    var body: some View {
      // 左右 14 はカード内の行の余白と同じ。線を行の文字に揃える。
      Rectangle()
        .fill(colors.borderAlpha(7))
        .frame(height: px(1))
        .padding(.horizontal, px(14))
    }
  }
#endif
