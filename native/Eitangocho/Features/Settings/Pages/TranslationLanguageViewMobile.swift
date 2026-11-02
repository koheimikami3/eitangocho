#if os(iOS)
  import SwiftUI

  /// iOS 版の「訳の言語」の画面(設定から押して進む)。言語の説明文もこの画面に置く。
  struct TranslationLanguageViewMobile: View {
    let settings: SettingsStore

    var body: some View {
      MobileSettingsSubpage(title: String(localized: .sectionTranslation)) {
        MobileSettingsSection(title: nil) {
          ForEach(
            AppLocale.deviceTranslationLanguageChoices(current: settings.translationLanguage), id: \.self
          ) { language in
            MobileSettingsRadioRow(
              label: String(localized: language.label), selected: settings.translationLanguage == language
            ) { settings.setTranslationLanguage(language) }
          }
        }
        MobileSettingsCaption(text: String(localized: .translationLanguageCaption))
      }
    }
  }
#endif
