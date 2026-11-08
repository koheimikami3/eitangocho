#if os(iOS)
  import EitangochoData
  import UIKit

  /// iOS 版の削除の確認ダイアログ。OS のアラート(UIAlertController)で出す。
  ///
  /// iOS 26 以降はアラートが Liquid Glass になり、自前で描いたダイアログだけが前の見た目のまま浮いて見えるため、OS のものに替えた
  /// (2026-11-09 のユーザー判断)。macOS は表示倍率に従わず小さく見えるので、自前の DeleteConfirmDialog のまま。
  enum MobileDeleteConfirmDialog {
    /// 確定すると `onDeleted` を呼び(編集シートを閉じるのに使う)、削除する。
    @MainActor
    static func present(_ word: Word, store: WordStore, onDeleted: @escaping () -> Void) {
      guard let presenter = UIApplication.shared.topViewController else { return }
      let alert = UIAlertController(
        title: String(localized: .deleteConfirmTitle(word.word)), message: String(localized: .deleteConfirmBody),
        preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: String(localized: .deleteConfirmCancel), style: .cancel))
      alert.addAction(
        UIAlertAction(title: String(localized: .deleteConfirmOk), style: .destructive) { _ in
          // シートは削除の書き込みを待たずに閉じる。待つと、アラートが消えてからシートが閉じるまでに間が空く。
          onDeleted()
          Task { await store.delete(word) }
        })
      presenter.present(alert, animated: true)
    }
  }
#endif
