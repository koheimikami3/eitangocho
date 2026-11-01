#if os(iOS)
  import SwiftUI

  /// iOS 版の丸いアイコンのボタン(ヘッダ右上の 🔍・＋、シートの ✕・‹、押して進む画面の ‹)。
  ///
  /// iOS 26 以降は Liquid Glass にする。`prominent` はアクセント色を付けたガラス(主な操作)。
  /// iOS 18 はガラスが無いので、同じ大きさの丸で代える(2026-10-31 に決めた案 A):
  /// `prominent` は主ボタンと同じグラデーションと影、そうでなければ面の色の丸をカードと同じ影で浮かせる。
  struct MobileGlassCircleButton: View {
    let systemName: String
    /// 読み上げの名前(アイコンだけで文字が無いため)。
    let accessibilityLabel: String
    var iconSize: CGFloat = 17
    var prominent = false
    let action: () -> Void

    @Environment(\.palette) private var palette

    /// ボタンの直径(ヘッダのタイトルの行の高さ 44 と同じ)。
    static let diameter: CGFloat = 44

    var body: some View {
      if #available(iOS 26, *) {
        Button(action: action) { icon }
          .buttonStyle(.plain)
          .glassEffect(prominent ? .regular.tint(palette.accent).interactive() : .regular.interactive(), in: .circle)
      } else if prominent {
        MobilePressable(action: action) {
          icon
            .background(Circle().fill(palette.buttonFill))
            .appShadows(palette.buttonShadow, in: Circle(), scale: 1)
        }
      } else {
        MobilePressable(action: action) {
          icon
            .background(Circle().fill(palette.surface))
            .appShadows(palette.elevation, in: Circle(), scale: 1)
        }
      }
    }

    private var icon: some View {
      Image(systemName: systemName)
        .font(.system(size: iconSize, weight: .semibold))
        .foregroundStyle(prominent ? .white : palette.text)
        .frame(width: Self.diameter, height: Self.diameter)
        .contentShape(Circle())
        .accessibilityLabel(Text(verbatim: accessibilityLabel))
    }
  }

  /// iOS 版の文字の主ボタン(シート右上の「登録」「保存」)。高さは丸いボタンと揃える。
  ///
  /// iOS 26 以降はアクセント色のガラスのカプセル(ヘッダの ＋ と同じ)。iOS 18 は主ボタンと同じグラデーションのピル形。
  struct MobileGlassCapsuleButton: View {
    let label: String
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
      if #available(iOS 26, *) {
        Button(action: action) { text }
          .buttonStyle(.plain)
          .glassEffect(.regular.tint(palette.accent).interactive(), in: .capsule)
      } else {
        MobilePressable(action: action) {
          text
            .background(Capsule().fill(palette.buttonFill))
            .appShadows(palette.buttonShadow, in: Capsule(), scale: 1)
        }
      }
    }

    private var text: some View {
      AppText(label, style: AppTextStyle(size: 15, weight: .w700))
        .foregroundStyle(.white)
        .padding(.horizontal, 18)
        .frame(height: MobileGlassCircleButton.diameter)
        .contentShape(Capsule())
    }
  }
#endif
