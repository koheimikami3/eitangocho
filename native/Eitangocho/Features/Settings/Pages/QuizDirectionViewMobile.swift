#if os(iOS)
  import SwiftUI

  /// iOS 版の「クイズの出題」の画面(英語 → 訳 / 訳 → 英語。設定から押して進む)。
  struct QuizDirectionViewMobile: View {
    let settings: SettingsStore

    var body: some View {
      MobileSettingsSubpage(title: String(localized: .quizDirection)) {
        MobileSettingsSection(title: nil) {
          ForEach(QuizDirection.allCases, id: \.self) { direction in
            MobileSettingsRadioRow(
              label: String(localized: direction.label(settings.translationLanguage)),
              selected: settings.quizDirection == direction
            ) { settings.setQuizDirection(direction) }
          }
        }
      }
    }
  }
#endif
