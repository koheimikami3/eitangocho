#if os(iOS)
  import EitangochoData
  import SwiftUI

  /// iOS 版の全単語リスト(Flutter 版の AllWordsViewMobile)。macOS 版の表に代わる 1 行 1 単語のリスト。
  struct AllWordsViewMobile: View {
    let store: WordStore
    let shell: MainShellModel
    let settings: SettingsStore
    let onEdit: (Word) -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      let words = WordListing.filteredAll(store.words, query: shell.searchQuery, order: settings.wordSortOrder)
      if !store.isLoaded {
        MobileLoadingIndicator()
      } else if words.isEmpty {
        AppText(.noWordsYet, style: AppTextStyle(size: 14))
          .foregroundStyle(palette.textAlpha(45))
          .multilineTextAlignment(.center)
          .padding(32)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        ScrollView {
          LazyVStack(spacing: 0) {
            ForEach(words) { word in
              // macOS 版の表は showIpa を無視して常に出すが、iOS は幅が厳しく IPA の有無で行の見え方が変わるため、設定に従わせる。
              MobileWordRow(
                word: word, showIpa: settings.showIpa,
                showCorrectCount: settings.wordSortOrder.group == .correctCount,
                onToggleLearned: { value in Task { await store.setLearned(word, value) } },
                onTap: { onEdit(word) })
            }
          }
        }
      }
    }
  }
#endif
