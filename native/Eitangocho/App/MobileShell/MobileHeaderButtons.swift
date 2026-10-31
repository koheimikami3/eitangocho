#if os(iOS)
  import SwiftUI

  /// iOS 版ヘッダ右上の 🔍(検索欄を開く)と ＋(登録シートを開く)の丸いボタン。
  ///
  /// iOS 26 以降は Liquid Glass にする(下のタブバーと画面の上下で見た目を揃える。docs の第 5 節の例外)。
  /// ＋ は登録というアプリの主な操作なので、アクセント色を付けたガラスにして目立ち方を保つ。
  /// iOS 18 はガラスが無いので、同じ位置・大きさの丸で代える(2026-10-31 に決めた案 A):
  /// ＋ は主ボタンと同じグラデーションと影、🔍 は面の色の丸をカードと同じ影で浮かせる。
  struct MobileHeaderButtons: View {
    let onSearch: () -> Void
    let onAdd: () -> Void

    @Environment(\.palette) private var palette

    /// ボタンの直径(ヘッダのタイトルの行の高さ 44 と同じ)。
    static let diameter: CGFloat = 44
    private static var spacing: CGFloat { 8 }

    var body: some View {
      if #available(iOS 26, *) {
        GlassEffectContainer(spacing: Self.spacing) {
          HStack(spacing: Self.spacing) {
            Button(action: onSearch) { searchIcon }
              .buttonStyle(.plain)
              .glassEffect(.regular.interactive(), in: .circle)
            Button(action: onAdd) { addIcon }
              .buttonStyle(.plain)
              .glassEffect(.regular.tint(palette.accent).interactive(), in: .circle)
          }
        }
      } else {
        HStack(spacing: Self.spacing) {
          MobilePressable(action: onSearch) {
            searchIcon
              .background(Circle().fill(palette.surface))
              .appShadows(palette.elevation, in: Circle(), scale: 1)
          }
          MobilePressable(action: onAdd) {
            addIcon
              .background(Circle().fill(palette.buttonFill))
              .appShadows(palette.buttonShadow, in: Circle(), scale: 1)
          }
        }
      }
    }

    private var searchIcon: some View {
      Image(systemName: "magnifyingglass")
        .font(.system(size: 17, weight: .semibold))
        .foregroundStyle(palette.text)
        .frame(width: Self.diameter, height: Self.diameter)
        .contentShape(Circle())
        .accessibilityLabel(Text(.search))
    }

    private var addIcon: some View {
      Image(systemName: "plus")
        .font(.system(size: 19, weight: .semibold))
        .foregroundStyle(.white)
        .frame(width: Self.diameter, height: Self.diameter)
        .contentShape(Circle())
        .accessibilityLabel(Text(.navRegistration))
    }
  }
#endif
