#if os(iOS)
  import SwiftUI

  /// iOS 版の「発音」の画面(Google 翻訳 / 端末の読み上げ。設定から押して進む)。
  struct PronunciationMethodViewMobile: View {
    let settings: SettingsStore

    var body: some View {
      MobileSettingsSubpage(title: String(localized: .pronunciationMethod)) {
        MobileSettingsSection(title: nil) {
          ForEach(PronunciationMethod.allCases, id: \.self) { method in
            MobileSettingsRadioRow(
              label: String(localized: method.label), selected: settings.pronunciationMethod == method
            ) { settings.setPronunciationMethod(method) }
          }
        }
      }
    }
  }
#endif
