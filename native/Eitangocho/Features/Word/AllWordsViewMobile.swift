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
      let words = WordListing.filteredAll(
        store.words, query: shell.searchQuery, order: settings.wordSortOrder, bookmarksOnly: shell.bookmarksOnly)
      if !store.isLoaded {
        MobileLoadingIndicator()
      } else if words.isEmpty {
        // ブックマークで絞っていて 1 語も付いていなければ、🔖 の付け方を案内する(単語が無いのではないため)。
        // 付いていても検索で 0 語になったときは、この案内は出さない。
        let noBookmarks =
          shell.bookmarksOnly && !store.words.isEmpty && !store.words.contains(where: \.isBookmarked)
        AppText(noBookmarks ? .noBookmarksYet : .noWordsYet, style: AppTextStyle(size: 14, height: 1.6))
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
                onToggleBookmark: { value in Task { await store.setBookmarked(word, value, screen: .allWords) } },
                onTap: { onEdit(word) })
            }
          }
          // 一番下までスクロールしたとき、最後の行と右下の ＋ の間を学習中(カードの下の余白)と同じだけ空ける。
          .padding(.bottom, AppDimensions.mobilePadding)
        }
        // 絞り込み(検索・ブックマーク)が変わったら、スクロールを作り直して先頭から見せる。
        // 下までスクロールした状態で件数が大きく減ると、LazyVStack は前の位置のまま中身の無い範囲を描き、
        // 単語があるのに一覧が空に見えることがある(2026-11-08 のユーザーの報告)。
        .id(FilterKey(query: shell.searchQuery, bookmarksOnly: shell.bookmarksOnly))
      }
    }

    /// スクロールを作り直すきっかけ(一覧の中身が入れ替わる絞り込み)。
    private struct FilterKey: Hashable {
      let query: String
      let bookmarksOnly: Bool
    }
  }
#endif
