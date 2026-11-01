#if os(iOS)
  import SwiftUI

  /// iOS 版のライセンスの一覧(設定から押して進む画面。Flutter 版の LicenseViewMobile)。
  ///
  /// 一覧の中身は macOS 版と同じ LicenseCatalog。一覧の下の「この一覧はビルド時に自動生成されます。」は
  /// Swift 版では事実と違うので出さない(macOS 版と同じ)。
  struct LicenseViewMobile: View {
    @Environment(\.palette) private var palette
    @Environment(\.appOverlay) private var overlay
    @State private var items: Result<[LicenseItem], Error> = Result { try LicenseCatalog.load() }

    var body: some View {
      MobilePushPage(title: String(localized: .licenses), backLabel: String(localized: .navSettings)) {
        switch items {
        case .success(let items):
          ScrollView {
            LazyVStack(spacing: 0) {
              ForEach(items) { item in
                MobileLicenseRow(item: item) {
                  overlay?.push { LicenseDetailViewMobile(item: item) }
                }
              }
            }
            .padding(.bottom, 40)
          }
        case .failure:
          AppText(.licenseLoadFailed, style: AppTextStyle(size: 13))
            .foregroundStyle(palette.textAlpha(45))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
    }
  }

  private struct MobileLicenseRow: View {
    let item: LicenseItem
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      HStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 2) {
          AppText(item.name, style: AppTextStyle(size: 15))
            .foregroundStyle(palette.text)
          AppText(item.summary ?? String(localized: .licenseCount(item.texts.count)), style: AppTextStyle(size: 12))
            .foregroundStyle(palette.textAlpha(45))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        AppText("›", style: AppTextStyle(size: 16, height: 1))
          .foregroundStyle(palette.textAlpha(30))
      }
      // 下の線の太さの分は下の余白に足す(Flutter の Container は枠線の幅を内側の余白に足す)。
      .padding(EdgeInsets(top: 13, leading: 16, bottom: 13 + 1, trailing: 16))
      .overlay(alignment: .bottom) {
        Rectangle().fill(palette.rowLine).frame(height: 1)
      }
      .contentShape(Rectangle())
      .onTapGesture(perform: action)
    }
  }
#endif
