#if os(iOS)
  import SwiftUI

  /// iOS 版のライセンスの全文(一覧から押して進む画面。Flutter 版の LicenseDetailViewMobile)。複数あるときは区切り線を挟む。
  struct LicenseDetailViewMobile: View {
    let item: LicenseItem

    @Environment(\.palette) private var palette

    var body: some View {
      MobilePushPage(title: String(localized: .licenses), backLabel: String(localized: .licenses)) {
        ScrollView {
          VStack(alignment: .leading, spacing: 0) {
            AppText(item.name, style: AppTextStyle(size: 15, weight: .w600))
              .foregroundStyle(palette.text)
            Spacer().frame(height: 16)
            ForEach(Array(item.texts.enumerated()), id: \.offset) { index, text in
              if index > 0 {
                Rectangle().fill(palette.rowLine).frame(height: 1).padding(.vertical, 20)
              }
              AppText(text, style: AppTextStyle(size: 12, height: 1.7))
                .foregroundStyle(palette.textAlpha(70))
                .textSelection(.enabled)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(EdgeInsets(top: 16, leading: 16, bottom: 40, trailing: 16))
        }
      }
    }
  }
#endif
