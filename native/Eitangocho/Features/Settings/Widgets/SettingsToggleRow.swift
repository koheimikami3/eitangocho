#if os(macOS)
  import SwiftUI

  /// トグルスイッチの行。プロトタイプの自前のトグル(トラック 42×26・白いつまみ 20×20)。
  /// Flutter 版の SettingsToggleRow。行ではなくトグルだけが押せる。
  struct SettingsToggleRow: View {
    let label: String
    let value: Bool
    let onChange: (Bool) -> Void

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    var body: some View {
      HStack(spacing: 0) {
        AppText(label, style: SettingsRowStyle.label)
          .foregroundStyle(colors.textPrimary)
          .frame(maxWidth: .infinity, alignment: .leading)
        toggle
      }
      .padding(px(SettingsRowStyle.padding))
    }

    private var toggle: some View {
      ZStack(alignment: .topLeading) {
        // OFF はプロトタイプの rgba(0,0,0,0.18)。
        Capsule().fill(value ? colors.accent : colors.borderAlpha(18))
        Circle()
          .fill(.white)
          .frame(width: px(20), height: px(20))
          .appShadows([AppShadow(color: Color(argb: 0x4000_0000), blurRadius: 3, y: 1)], in: Circle(), scale: px.factor)
          .offset(x: px(value ? 19 : 3), y: px(3))
      }
      .frame(width: px(42), height: px(26))
      .animation(.easeInOut(duration: 0.15), value: value)
      .contentShape(Capsule())
      .onTapGesture { onChange(!value) }
      .pointerStyle(.link)
    }
  }
#endif
