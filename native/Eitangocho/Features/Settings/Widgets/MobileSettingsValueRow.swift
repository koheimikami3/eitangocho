#if os(iOS)
  import SwiftUI

  /// iOS 版の設定の行(ラベル + 右端に値。バージョンなどの読み取り専用の行。Flutter 版の MobileSettingsValueRow)。
  struct MobileSettingsValueRow: View {
    let label: String
    let value: String

    @Environment(\.palette) private var palette

    var body: some View {
      HStack(spacing: 0) {
        AppText(label, style: AppTextStyle(size: 14))
          .foregroundStyle(palette.text)
          .frame(maxWidth: .infinity, alignment: .leading)
        AppText(value, style: AppTextStyle(size: 13))
          .foregroundStyle(palette.textAlpha(40))
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 13)
    }
  }
#endif
