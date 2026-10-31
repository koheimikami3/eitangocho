#if os(iOS)
  import SwiftUI

  /// iOS 版の設定の行(ラベル + 右端のシェブロン。押すと別の画面へ進む・処理を始める。Flutter 版の MobileSettingsLinkRow)。
  struct MobileSettingsLinkRow: View {
    let label: String
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      MobilePressable(style: .row, action: action) { pressed in
        HStack(spacing: 0) {
          AppText(label, style: AppTextStyle(size: 14))
            .foregroundStyle(palette.text)
            .frame(maxWidth: .infinity, alignment: .leading)
          AppText("›", style: AppTextStyle(size: 16, height: 1))
            .foregroundStyle(palette.textAlpha(30))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(pressed ? palette.pressBackground : .clear)
      }
    }
  }
#endif
