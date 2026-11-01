#if os(iOS)
  import SwiftUI

  /// iOS 版の設定のトグルの行(ラベル + iOS 風のスイッチ 50×30。Flutter 版の MobileSettingsToggleRow)。行全体がタップ領域。
  struct MobileSettingsToggleRow: View {
    let label: String
    let value: Bool
    let onChanged: (Bool) -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      HStack(spacing: 0) {
        AppText(label, style: AppTextStyle(size: 14))
          .foregroundStyle(palette.text)
          .frame(maxWidth: .infinity, alignment: .leading)
        Capsule()
          .fill(value ? palette.accent : palette.toggleOff)
          .frame(width: 50, height: 30)
          .overlay(alignment: value ? .trailing : .leading) {
            Circle()
              .fill(.white)
              .frame(width: 24, height: 24)
              .appShadows([AppShadow(color: Color(argb: 0x4000_0000), blurRadius: 3, y: 1)], in: Circle(), scale: 1)
              .padding(.horizontal, 3)
          }
          // Flutter 版の AnimatedContainer / AnimatedAlign(150 ms・直線)。
          .animation(.linear(duration: 0.15), value: value)
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 12)
      .contentShape(Rectangle())
      .onTapGesture { onChanged(!value) }
    }
  }
#endif
