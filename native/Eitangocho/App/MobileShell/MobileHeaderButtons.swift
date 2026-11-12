#if os(iOS)
  import SwiftUI

  /// iOS 版ヘッダ右上の 🔍(検索欄を開く)と ⚙(設定を開く)の丸いボタン。
  ///
  /// iOS 26 以降は Liquid Glass にする(下のタブバーと画面の上下で見た目を揃える。docs の第 5 節の例外)。
  /// iOS 18 の代わりの見た目は `MobileGlassCircleButton` が持つ。
  /// ＋(登録)はここに置かず、片手の親指が届く右下に浮かせる(MobileAddButton。試作)。
  /// 設定はたまにしか開かないのでタブバーから外し、ここから下のシートで開く(試作)。🔍 は学習中 / 全単語だけ。
  /// ガラスをまとめる GlassEffectContainer はヘッダの行が持つ(🔍 が同じ行の検索欄へ形を変えるため)。
  struct MobileHeaderButtons: View {
    let namespace: Namespace.ID
    let showsSearch: Bool
    let onSearch: () -> Void
    let onSettings: () -> Void

    static let spacing: CGFloat = 8
    /// 絵柄の大きさ。丸(44pt)に対して既定の 17pt だと小さく細く見えるため、丸は変えずに絵柄だけ大きくする(試作)。
    private static let iconSize: CGFloat = 20

    var body: some View {
      HStack(spacing: Self.spacing) {
        if showsSearch {
          MobileGlassCircleButton(
            systemName: "magnifyingglass", accessibilityLabel: String(localized: .search), iconSize: Self.iconSize,
            glassID: MobileGlassID(id: MobileSearchField.searchGlassID, namespace: namespace), action: onSearch)
        }
        MobileGlassCircleButton(
          systemName: "gearshape", accessibilityLabel: String(localized: .navSettings), iconSize: Self.iconSize,
          action: onSettings)
      }
    }
  }
#endif
