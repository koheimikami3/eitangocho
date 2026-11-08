#if os(iOS)
  import EitangochoData
  import SwiftUI

  /// iOS 版の学習中(未学習)単語のカード(Flutter 版の LearningWordsViewMobile)。1 列 / 2 列は設定で選ぶ。
  struct LearningWordsViewMobile: View {
    let store: WordStore
    let shell: MainShellModel
    let settings: SettingsStore
    /// 登録したばかりの見出し語。そのカードを弾ませて、まわりに波紋を添える(MobileCardPop)。
    var celebratedWord: String?
    let onEdit: (Word) -> Void
    let onRegister: () -> Void

    /// 一覧の一番上(余白を含む)へ戻すときの目印。
    private static let topID = "learningTop"

    var body: some View {
      let words = WordListing.filteredLearning(store.words, query: shell.searchQuery)
      if !store.isLoaded {
        MobileLoadingIndicator()
      } else if words.isEmpty {
        MobileLearningEmptyState(onRegister: onRegister)
      } else {
        let columns = settings.cardLayout.columns
        ScrollViewReader { proxy in
          ScrollView {
            // 説明文は置かない(iOS は画面が狭く、操作もチェックとタップだけで自明なため)。
            // 高さは内容なりにして行ごとに上で揃える(デザインの grid の align-items:start。Flutter 版は Wrap)。
            CardGrid(gap: AppDimensions.mobileGridGap, columns: columns) {
              ForEach(words) { word in
                // id で同じカードを保つので、検索や削除での組み直しでは訳の表示の状態が残り、再び出現しない。
                MobileWordCard(
                  word: word, showIpa: settings.showIpa, singleColumn: columns == 1,
                  onToggleLearned: { value in Task { await store.setLearned(word, value) } },
                  onToggleFavorite: { value in Task { await store.setFavorite(word, value, view: .learning) } },
                  onTap: { onEdit(word) }
                )
                .modifier(CardIn())
                .modifier(MobileCardPop(active: word.word == celebratedWord))
                .id(word.id)
              }
            }
            .padding(AppDimensions.mobilePadding)
            // 先頭へ戻すときの目印。余白ごと付けるので、上の余白まで含めた一番上に戻る。
            .id(Self.topID)
          }
          // 新しいカードは先頭に入るので、下までスクロールしていても演出が見えるよう先頭へ戻す
          // (シートの裏で戻すので、動きは見せない)。
          .onChange(of: celebratedWord) { _, word in
            if word != nil { proxy.scrollTo(Self.topID, anchor: .top) }
          }
        }
      }
    }
  }
#endif
