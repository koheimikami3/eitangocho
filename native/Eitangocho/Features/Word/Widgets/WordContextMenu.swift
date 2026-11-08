import EitangochoData
import SwiftUI

/// 右クリックの「お気に入りに追加 / から外す」「編集...」「削除...」のメニュー(Flutter 版の showWordContextMenu)。macOS 専用。
/// 学習中のカードと全単語の行が同じメニューを出すので、編集・削除のダイアログまでここでつなぐ。
/// `view` はメニューを開いた画面(お気に入りの計測用)。
enum WordContextMenu {
  @MainActor
  static func show(
    at position: CGPoint, word: Word, store: WordStore, language: TranslationLanguage, view: MainView,
    overlay: AppOverlay?, colors: AppColors
  ) {
    let favoriteLabel: LocalizedStringResource = word.isFavorite ? .removeFromFavorites : .addToFavorites
    overlay?.showMenu(
      at: position,
      items: [
        AppOverlay.MenuItem(label: String(localized: favoriteLabel)) {
          Task { await store.setFavorite(word, !word.isFavorite, view: view) }
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
