#if os(macOS)
  import SwiftUI

  /// macOS 版の設定のテーマカラー(8 色の丸を 1 行に並べる。2.18.0)。選ぶとすぐアプリ全体の色が変わる。
  ///
  /// iOS の ThemeColorViewMobile と同じく、未購入のときはブルー以外に鍵を付け、押すと Pro 版の案内
  /// (ProOfferDialog)を出す。macOS は横幅に余裕があるので、次の階層の画面には分けない。
  struct ThemeColorPicker: View {
    let settings: SettingsStore

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    @Environment(\.purchase) private var purchase
    @Environment(\.appOverlay) private var overlay
    @Environment(\.analytics) private var analytics

    var body: some View {
      let unlocked = purchase?.proUnlocked ?? false
      HStack(spacing: 0) {
        ForEach(ThemeColor.allCases, id: \.self) { color in
          let locked = !unlocked && color != ThemeColor.free
          // 選択中の印は今の画面の色(colors.theme)で出す。未購入なら保存した色ではなくブルーに付く。
          ThemeColorSwatch(color: color, selected: colors.theme == color, locked: locked) {
            if locked {
              analytics.logThemeColorLockedTapped()
              ProOfferDialog.present(purchase: purchase, source: .themeColor, overlay: overlay)
            } else {
              settings.setThemeColor(color)
            }
          }
        }
      }
      .padding(EdgeInsets(top: px(14), leading: px(8), bottom: px(14), trailing: px(8)))
    }
  }

  /// 色の一覧の 1 色(丸い見本)。選択中は中央にチェック、鍵付きは中央に鍵を出す(iOS と同じ)。
  /// 色の名前は出さず、ツールチップと読み上げにだけ渡す。
  private struct ThemeColorSwatch: View {
    let color: ThemeColor
    let selected: Bool
    let locked: Bool
    let action: () -> Void

    @Environment(\.colors) private var colors
    @Environment(\.uiScale) private var px
    @State private var isHovered = false

    var body: some View {
      ZStack {
        // 見本はその色の今の配色(ライト / ダーク)でのアクセント。グラファイトはダークで明るい方を出す。
        Circle().fill(AppColors(isDark: colors.isDark, theme: color).accent)
        if selected {
          Image(systemName: "checkmark")
            .font(.system(size: px(13), weight: .bold))
            .foregroundStyle(.white)
        } else if locked {
          Image(systemName: "lock.fill")
            .font(.system(size: px(8), weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: px(16), height: px(16))
            .background(Circle().fill(Color.black.opacity(0.28)))
        }
      }
      .frame(width: px(34), height: px(34))
      // 押せることが分かるよう、ホバー中は少し大きくする。
      .scaleEffect(isHovered ? 1.08 : 1)
      .animation(.easeOut(duration: 0.12), value: isHovered)
      .frame(maxWidth: .infinity)
      .hoverTap($isHovered, in: Circle(), action: action)
      .pointerStyle(.link)
      .help(Text(color.label))
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(Text(color.label))
      .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }
  }
#endif
