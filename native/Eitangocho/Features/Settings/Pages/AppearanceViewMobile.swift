#if os(iOS)
  import SwiftUI

  /// iOS 版の「外観モード」の画面(端末の設定と同じ / ライト / ダーク。設定から押して進む)。
  struct AppearanceViewMobile: View {
    let settings: SettingsStore

    var body: some View {
      MobileSettingsSubpage(title: String(localized: .appearanceMode)) {
        MobileSettingsSection(title: nil) {
          ForEach(AppAppearance.allCases, id: \.self) { appearance in
            MobileSettingsRadioRow(
              label: String(localized: appearance.label), selected: settings.appearance == appearance
            ) { settings.setAppearance(appearance) }
          }
        }
      }
    }
  }
#endif
