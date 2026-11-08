import EitangochoData
import SwiftUI

/// 右クリックの「ブックマークに追加 / から外す」「編集...」「削除...」のメニュー(Flutter 版の showWordContextMenu)。macOS 専用。
/// 学習中のカードと全単語の行が同じメニューを出すので、編集・削除のダイアログまでここでつなぐ。
/// `screen` はメニューを開いた画面(ブックマークの計測用)。
enum WordContextMenu {
  @MainActor
  static func show(
    at position: CGPoint, word: Word, store: WordStore, language: TranslationLanguage, screen: BookmarkScreen,
    overlay: AppOverlay?, colors: AppColors
  ) {
    let bookmarkLabel: LocalizedStringResource = word.isBookmarked ? .removeBookmark : .addBookmark
    overlay?.showMenu(
      at: position,
      items: [
        AppOverlay.MenuItem(label: String(localized: bookmarkLabel)) {
          Task { await store.setBookmarked(word, !word.isBookmarked, screen: screen) }
        },
        .divider,
        AppOverlay.MenuItem(label: String(localized: .editEllipsis)) {
          EditWordDialog.present(word, store: store, language: language, overlay: overlay)
        },
        AppOverlay.MenuItem(label: String(localized: .deleteEllipsis), color: colors.danger, hoverColor: colors.danger) {
          DeleteConfirmDialog.present(word, store: store, overlay: overlay)
        },
      ])
  }
}
