import EitangochoData
import SwiftUI

/// 全単語の表(Flutter 版の AllWordsView)。
///
/// 画面が表の最小幅より狭いときは横にスクロールさせる(表示倍率を上げた状態で
/// ウィンドウを狭めても列がはみ出さない)。
struct AllWordsView: View {
  let store: WordStore
  let shell: MainShellModel
  let settings: SettingsStore

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px
  @Environment(\.appOverlay) private var overlay

  var body: some View {
    let words = WordListing.filteredAll(store.words, query: shell.searchQuery, order: settings.wordSortOrder)
    let language = settings.translationLanguage
    GeometryReader { geometry in
      // 列幅は素の値で決める(倍率を掛ける前の幅に直す)。
      let tableWidth = max(geometry.size.width / px.factor, AppDimensions.tableMinWidth)
      let columns = WordTableColumns(tableWidth: tableWidth)
      ScrollView(.horizontal) {
        VStack(spacing: 0) {
          WordTableHeader(columns: columns, meaningLabel: String(localized: language.meaningColumnLabel))
          ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
              ForEach(words) { word in
                WordTableRow(
                  word: word,
                  columns: columns,
                  showCorrectCount: settings.wordSortOrder.group == .correctCount,
                  onToggleLearned: { value in Task { await store.setLearned(word, value) } },
                  onTap: { EditWordDialog.present(word, store: store, language: language, overlay: overlay) },
                  onContextMenu: { position in
                    WordContextMenu.show(
                      at: position, word: word, overlay: overlay, colors: colors,
                      onEdit: { EditWordDialog.present(word, store: store, language: language, overlay: overlay) },
                      onDelete: { DeleteConfirmDialog.present(word, store: store, overlay: overlay) })
                  })
              }
            }
          }
        }
        .frame(width: px(tableWidth), height: geometry.size.height)
      }
      .scrollDisabled(geometry.size.width / px.factor >= AppDimensions.tableMinWidth)
    }
  }
}
