#if os(macOS)
  import SwiftUI

  /// ラジオボタンの行。行のどこを押しても選べる。プロトタイプの自前のラジオ
  /// (16×16 の円・選択中は accent の塗り + 白い点)。Flutter 版の SettingsRadioRow。
  struct SettingsRadioRow: View {
    let label: String
    let selected: Bool
    let action: () -> Void

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    var body: some View {
      HStack(spacing: px(10)) {
        ZStack {
          Circle().fill(selected ? colors.accent : colors.inputFill)
          Circle().strokeBorder(
            selected ? colors.accent : colors.controlBorder, lineWidth: px(selected ? 1 : 1.5))
          Circle()
            .fill(.white)
            .frame(width: px(6), height: px(6))
            .opacity(selected ? 1 : 0)
        }
        .frame(width: px(16), height: px(16))
        .animation(.easeInOut(duration: 0.15), value: selected)
        AppText(label, style: SettingsRowStyle.label)
          .foregroundStyle(colors.textPrimary)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(px(SettingsRowStyle.padding))
      .contentShape(Rectangle())
      .onTapGesture(perform: action)
      .pointerStyle(.link)
    }
  }
#endif
