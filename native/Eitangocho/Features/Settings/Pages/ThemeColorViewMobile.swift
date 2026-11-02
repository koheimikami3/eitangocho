#if os(iOS)
  import SwiftUI

  /// iOS 版の「テーマカラー」の画面(8 色の一覧。設定から押して進む)。選ぶとすぐアプリ全体の色が変わる。
  ///
  /// 未購入のときはブルー以外に鍵を付け、押すとその場で Pro の購入を始める(設定のトップの Pro の欄と同じ購入)。
  /// 色の一覧から設定のトップへ戻らせずに済むようにするため。買えたら、そのまま選べる状態になる。
  struct ThemeColorViewMobile: View {
    let settings: SettingsStore

    @Environment(\.palette) private var palette
    @Environment(\.purchase) private var purchase

    private static let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 4)

    var body: some View {
      let unlocked = purchase?.proUnlocked ?? false
      MobileSettingsSubpage(title: String(localized: .themeColor)) {
        MobileSettingsSection(title: nil) {
          LazyVGrid(columns: Self.columns, spacing: 12) {
            ForEach(ThemeColor.allCases, id: \.self) { color in
              let locked = !unlocked && color != ThemeColor.free
              // 選択中の印は今の画面の色(palette.theme)で出す。未購入なら保存した色ではなくブルーに付く。
              ThemeColorSwatch(color: color, selected: palette.theme == color, locked: locked) {
                if locked {
                  if let purchase { Task { await purchase.buy() } }
                } else {
                  settings.setThemeColor(color)
                }
              }
            }
          }
          .padding(EdgeInsets(top: 14, leading: 8, bottom: 14, trailing: 8))
        }
        if !unlocked {
          MobileSettingsCaption(text: String(localized: .themeColorProCaption))
        }
      }
    }
  }

  /// 色の一覧の 1 色(丸い見本 + 色の名前)。選択中は中央にチェック、鍵付きは中央に鍵を出す。
  private struct ThemeColorSwatch: View {
    let color: ThemeColor
    let selected: Bool
    let locked: Bool
    let action: () -> Void

    @Environment(\.palette) private var palette

    private static let diameter: CGFloat = 42

    var body: some View {
      MobilePressable(action: action) {
        VStack(spacing: 5) {
          ZStack {
            // 見本はその色の今の配色(ライト / ダーク)でのアクセント。グラファイトはダークで明るい方を出す。
            Circle().fill(AppPalette(isDark: palette.isDark, theme: color).accent)
            if selected {
              // 選択中は枠を付けず、中央のチェックだけで示す(デザインの決定)。
              Image(systemName: "checkmark")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
            } else if locked {
              Image(systemName: "lock.fill")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 18, height: 18)
                .background(Circle().fill(Color.black.opacity(0.28)))
            }
          }
          .frame(width: Self.diameter, height: Self.diameter)
          AppText(color.label, style: AppTextStyle(size: 11))
            .foregroundStyle(palette.textAlpha(60))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(Text(color.label))
      .accessibilityAddTraits(selected ? .isSelected : [])
    }
  }
#endif
