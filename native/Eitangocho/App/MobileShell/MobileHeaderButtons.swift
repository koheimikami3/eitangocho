#if os(iOS)
  import SwiftUI

  /// iOS 版ヘッダ右上の 🔍(検索欄を開く)と ＋(登録シートを開く)の丸いボタン。
  ///
  /// iOS 26 以降は Liquid Glass にする(下のタブバーと画面の上下で見た目を揃える。docs の第 5 節の例外)。
  /// ＋ は登録というアプリの主な操作なので、アクセント色を付けたガラスにして目立ち方を保つ。
  /// iOS 18 の代わりの見た目は `MobileGlassCircleButton` が持つ。
  /// ガラスをまとめる GlassEffectContainer はヘッダの行が持つ(🔍 が同じ行の検索欄へ形を変えるため)。
  struct MobileHeaderButtons: View {
    let namespace: Namespace.ID
    let onSearch: () -> Void
    let onAdd: () -> Void

    static let spacing: CGFloat = 8

    var body: some View {
      HStack(spacing: Self.spacing) {
        MobileGlassCircleButton(
          systemName: "magnifyingglass", accessibilityLabel: String(localized: .search),
          glassID: MobileGlassID(id: MobileSearchField.searchGlassID, namespace: namespace), action: onSearch)
        MobileGlassCircleButton(
          systemName: "plus", accessibilityLabel: String(localized: .navRegistration), iconSize: 19, prominent: true,
          glassID: MobileGlassID(id: "add", namespace: namespace), action: onAdd)
      }
    }
  }
#endif
