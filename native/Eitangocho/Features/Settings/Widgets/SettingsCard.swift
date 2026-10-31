#if os(macOS)
  import SwiftUI

  /// 設定画面のカード。子の行を縦に並べ、行の間に区切り線を挟む(Flutter 版の SettingsCard)。
  struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    var body: some View {
      let shape = RoundedRectangle(cornerRadius: px(AppDimensions.mobileCardRadius))
      VStack(spacing: 0) {
        Group(subviews: content()) { rows in
          ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
            if index > 0 { SettingsDivider() }
            row
          }
        }
      }
      .frame(maxWidth: .infinity)
      // iOS の設定のセクションと同じく枠線なし + 淡い影。
      .background(colors.surface)
      .clipShape(shape)
      .appShadows(colors.elevation, in: shape, scale: px.factor)
    }
  }

  /// 設定のカードの行に共通の寸法(Flutter 版の各行の EdgeInsets.symmetric(horizontal: 14, vertical: 11) と 13px の本文)。
  enum SettingsRowStyle {
    static let padding = EdgeInsets(top: 11, leading: 14, bottom: 11, trailing: 14)
    static let label = AppTextStyle(size: 13)
  }
#endif
