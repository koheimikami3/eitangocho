#if os(iOS)
  import SwiftUI

  /// iOS 版の「学習中カードの並び」の画面(2 列 / 1 列。設定から押して進む)。行の右端に並びの見本を添える。
  struct CardLayoutViewMobile: View {
    let settings: SettingsStore

    var body: some View {
      MobileSettingsSubpage(title: String(localized: .cardLayout)) {
        MobileSettingsSection(title: nil) {
          ForEach(LearningCardLayout.allCases, id: \.self) { layout in
            MobileSettingsRadioRow(
              label: String(localized: layout.label), selected: settings.cardLayout == layout,
              action: { settings.setCardLayout(layout) }
            ) {
              MobileCardLayoutPreview(layout: layout)
            }
          }
        }
      }
    }
  }
#endif
