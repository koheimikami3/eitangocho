#if os(iOS)
  import EitangochoData
  import SwiftUI

  /// iOS 版の学習中(未学習)単語のカード(Flutter 版の LearningWordsViewMobile)。1 列 / 2 列は設定で選ぶ。
  struct LearningWordsViewMobile: View {
    let store: WordStore
    let shell: MainShellModel
    let settings: SettingsStore
    let onEdit: (Word) -> Void
    let onRegister: () -> Void

    var body: some View {
      let words = WordListing.filteredLearning(store.words, query: shell.searchQuery)
      if !store.isLoaded {
        MobileLoadingIndicator()
      } else if words.isEmpty {
        MobileLearningEmptyState(onRegister: onRegister)
      } else {
        let columns = settings.cardLayout.columns
        ScrollView {
          // 説明文は置かない(iOS は画面が狭く、操作もチェックとタップだけで自明なため)。
          // 高さは内容なりにして行ごとに上で揃える(デザインの grid の align-items:start。Flutter 版は Wrap)。
          CardGrid(gap: AppDimensions.mobileGridGap, columns: columns) {
            ForEach(words) { word in
              // id で同じカードを保つので、検索や削除での組み直しでは訳の表示の状態が残り、再び出現しない。
              MobileWordCard(
                word: word, showIpa: settings.showIpa, singleColumn: columns == 1,
                onToggleLearned: { value in Task { await store.setLearned(word, value) } },
                onTap: { onEdit(word) }
              )
              .modifier(CardIn())
            }
          }
          .padding(AppDimensions.mobilePadding)
        }
      }
    }
  }
#endif
