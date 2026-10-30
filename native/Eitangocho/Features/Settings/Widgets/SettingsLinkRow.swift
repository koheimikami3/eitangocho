#if os(macOS)
  import SwiftUI

  /// リンクの行(ラベル + 右端のシェブロン)。押すと別の画面を開く。Flutter 版の SettingsLinkRow。
  struct SettingsLinkRow: View {
    let label: String
    let action: () -> Void

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    @State private var isHovered = false

    var body: some View {
      HStack(spacing: 0) {
        AppText(label, style: SettingsRowStyle.label)
          .foregroundStyle(colors.textPrimary)
          .frame(maxWidth: .infinity, alignment: .leading)
        AppText("›", style: AppTextStyle(size: 14, height: 1))
          .foregroundStyle(colors.textDisabled)
      }
      .padding(px(SettingsRowStyle.padding))
      .background(isHovered ? colors.inputBackground : .clear)
      .hoverTap($isHovered, in: Rectangle(), action: action)
      .pointerStyle(.link)
    }
  }
#endif
