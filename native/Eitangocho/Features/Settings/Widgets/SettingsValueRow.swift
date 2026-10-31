#if os(macOS)
  import SwiftUI

  /// 読み取り専用の行(ラベル + 右端に値)。バージョンの表示など。Flutter 版の SettingsValueRow。
  struct SettingsValueRow: View {
    let label: String
    let value: String

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px

    var body: some View {
      HStack(spacing: 0) {
        AppText(label, style: SettingsRowStyle.label)
          .foregroundStyle(colors.textPrimary)
          .frame(maxWidth: .infinity, alignment: .leading)
        AppText(value, style: SettingsRowStyle.label)
          .foregroundStyle(colors.textTertiary)
      }
      .padding(px(SettingsRowStyle.padding))
    }
  }
#endif
