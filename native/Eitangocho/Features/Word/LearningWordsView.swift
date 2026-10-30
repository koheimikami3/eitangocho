import EitangochoData
import SwiftUI

/// 学習中(未学習)の単語のカードの格子(Flutter 版の LearningWordsView)。
struct LearningWordsView: View {
  let store: WordStore
  let shell: MainShellModel
  let settings: SettingsStore

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @Environment(\.appOverlay) private var overlay

  var body: some View {
    let words = WordListing.filteredLearning(store.words, query: shell.searchQuery)
    if !store.isLoaded {
      CircularProgress(color: colors.accent)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    } else if words.isEmpty {
      LearningEmptyState { shell.selectView(.registration) }
    } else {
      ScrollView {
        CardGrid(minWidth: px(AppDimensions.cardMinWidth), gap: px(AppDimensions.gridGap)) {
          ForEach(words) { word in
            // id で同じカードを保つので、検索や削除での組み直しでは既存のカードは再び出現しない
            // (新しいカードと画面に戻ったときだけ出現のアニメーションが再生される)。
            card(word).modifier(CardIn())
          }
        }
        .padding(px(AppDimensions.contentPadding))
      }
    }
  }

  private func card(_ word: Word) -> some View {
    // 設定 showIpa はカードの IPA の表示だけに効く(表は常に出す)。
    WordCard(
      word: word,
      showIpa: settings.showIpa,
      meaningLabel: String(localized: settings.translationLanguage.showMeaningLabel),
      onToggleLearned: { value in Task { await store.setLearned(word, value) } },
      onTap: { EditWordDialog.present(word, store: store, language: settings.translationLanguage, overlay: overlay) },
      onContextMenu: { position in
        WordContextMenu.show(
          at: position, word: word, overlay: overlay, colors: colors,
          onEdit: { EditWordDialog.present(word, store: store, language: settings.translationLanguage, overlay: overlay) },
          onDelete: { DeleteConfirmDialog.present(word, store: store, overlay: overlay) })
      }
    )
  }
}
