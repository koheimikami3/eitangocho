import SwiftUI

/// iOS 版の配色。ライト / ダークの 2 セットを持つ(macOS 版は AppColors)。
///
/// 値は Flutter 版の `lib/constants/app_palette.dart` をそのまま写したもので、
/// 見た目の正はこちら(Swift 版)と Flutter 版の両方で揃えておく。値の由来(Claude Design の
/// iOS プロトタイプと 2.0.0〜2.2.0 の立体案)とユーザー判断の経緯は Flutter 版のコメントにある。
/// 立体案は輪郭を枠線ではなく影で出す: 地の上の面は `elevation` で浮かせ、入力欄などは
/// `wellShadow`(内側の影。描画は MobileWell)で沈める。
///
/// アクセント系のトークン(accent・accentSoft・accentOnSoft・accentLine・buttonGradient・buttonShadow)は
/// テーマカラー(`theme`)から作る。
///
/// 画面からは `@Environment(\.palette) private var palette` で引く。
nonisolated struct AppPalette: Equatable, Sendable {
  let isDark: Bool
  /// テーマカラー。未購入の人にはブルーを渡す(決めるのは RootView)。
  var theme: ThemeColor = .free

  static let light = AppPalette(isDark: false)
  static let dark = AppPalette(isDark: true)

  // MARK: - 面

  /// 画面の地の色(--bg)
  var background: Color { isDark ? Color(argb: 0xFF13_1315) : Color(argb: 0xFFF7_F8FA) }

  /// カード・シート・ヘッダなど、地の上に乗る面(--surface)
  var surface: Color { isDark ? Color(argb: 0xFF24_2427) : .white }

  /// 一段沈んだ面(--surface2)
  var surfaceAlt: Color { isDark ? Color(argb: 0xFF1B_1B1E) : Color(argb: 0xFFF7_F8FA) }

  /// リストのセクションヘッダ・学習済みの行・広告帯など(--surface3)
  var surfaceHeader: Color { isDark ? Color(argb: 0xFF1A_1A1C) : Color(argb: 0xFFEF_F1F5) }

  /// タブバー(半透明。背後がぼけている前提の色)(--tabbar)
  var tabBar: Color { isDark ? Color(argb: 0xE61C_1C1E) : Color(argb: 0xEBFA_FAFB) }

  /// 入力欄など内側の影で沈めた面(--wellBg)。ダークは面より暗くして沈んで見せる。
  /// ライトは 2.2.0 から沈めずに白地にしている。
  var wellBackground: Color { isDark ? Color(argb: 0xFF13_1315) : .white }

  /// 押下中のカード・行の地(--pressBg)
  var pressBackground: Color { isDark ? Color(argb: 0xFF32_3238) : Color(argb: 0xFFED_EEF1) }

  // MARK: - 文字・状態色

  /// 本文色(--text)
  var text: Color { isDark ? Color(argb: 0xFFF5_F5F7) : Color(argb: 0xFF1D_1D1F) }

  var danger: Color { isDark ? Color(argb: 0xFFFF_6B6B) : Color(argb: 0xFFC0_3030) }

  var autoFillBadgeBackground: Color { isDark ? Color(argb: 0x3830_A060) : Color(argb: 0xFFE2_F3E8) }
  var autoFillBadgeForeground: Color { isDark ? Color(argb: 0xFF6F_D39A) : Color(argb: 0xFF1C_7A3F) }
  var warningBannerBackground: Color { isDark ? Color(argb: 0x2EB4_9628) : Color(argb: 0xFFFD_F6E3) }
  var warningBannerForeground: Color { isDark ? Color(argb: 0xFFE8_C766) : Color(argb: 0xFF8A_6D1A) }
  var warningBannerBorder: Color { isDark ? Color(argb: 0x66C8_AA3C) : Color(argb: 0xFFEC_D9A0) }

  // MARK: - アクセント

  /// アクセント色。ブルーはライト / ダーク共通(アイコンと同色)で、グラファイトだけダークで明るくする。
  var accent: Color { opaque(isDark ? tones.accentDark : tones.accent) }

  /// 発音ボタンの淡い地(--acc-soft)。ダークは地が暗いぶん濃く敷く(22%。ライトは 12%)。
  /// ライトは macOS の AppColors.accentSoft(10%)とは別に持つ(刷新案 A で iOS だけ 12% に上げた)。
  var accentSoft: Color { isDark ? withAlpha(0x38, tones.accentDark) : withAlpha(0x1F, tones.accent) }

  /// 白地・淡いアクセントの地に置く文字・アイコン色(--acc-text)。押せる「文字」はすべてこの色にする。
  ///
  /// ブルーのライトの #1B78C2 は accentSoft の上で 4.14:1 と 4.5:1 に届かないが、
  /// 刷新案 A で accent と同じ色相に揃えるデザイン判断として採用した(白地の上では 4.65:1)。
  var accentOnSoft: Color { opaque(isDark ? tones.onSoftDark : tones.onSoftLight) }

  /// 発音ボタンの枠線(--acc-line)。ダークは文字色と同じ色相で引く。
  var accentLine: Color { isDark ? withAlpha(0x73, tones.onSoftDark) : withAlpha(0x6B, tones.accent) }

  /// 購入済みで押せなくなった購入ボタンの地。
  var proButtonDone: Color { isDark ? Color(argb: 0x1FFF_FFFF) : Color(argb: 0xFFEC_ECEF) }

  /// 購入済みの購入ボタンの文字色。ダークだけ 1 段明るいのはデザイン準拠。
  var proButtonDoneForeground: Color { textAlpha(isDark ? 60 : 50) }

  /// 主ボタンの地(--btnGrad。上 → 下)。上から下へわずかに暗くして膨らみを出す。
  var buttonGradient: [Color] {
    let (top, bottom) = isDark ? tones.gradientDark : tones.gradientLight
    return [opaque(top), opaque(bottom)]
  }

  /// 主ボタンの地の塗り(`buttonGradient` を上から下へ引いたもの)。
  var buttonFill: LinearGradient { LinearGradient(colors: buttonGradient, startPoint: .top, endPoint: .bottom) }

  /// 削除ボタンの輪郭(--dangerLine)と押下中の地(--dangerSoft)
  var dangerLine: Color { isDark ? Color(argb: 0x80FF_6B6B) : Color(argb: 0x73C0_3030) }
  var dangerSoft: Color { isDark ? Color(argb: 0x1FFF_6B6B) : Color(argb: 0x12C0_3030) }

  // MARK: - 線

  /// リスト行・カード内・設定のセクション内の区切り線。
  var rowLine: Color { borderAlpha(7) }

  /// 未チェックのチェックボックス・ラジオの枠線。ライトは青みの墨 rgba(18,22,32,0.38)。
  var checkOffBorder: Color { isDark ? borderAlpha(45) : Color(argb: 0xFF12_1620).opacity(0.38) }

  // MARK: - 立体案の影(デザインの box-shadow をそのまま移したもの)

  /// 地の上に浮かせる面(カード・設定のセクション・クイズカード)の影(--elev)。
  /// ダークは 1 枚目に白の細い輪郭(raisedOutline)を敷く。ライトは枠線なしの淡い影 2 枚。
  var elevation: [AppShadow] {
    isDark
      ? [
        raisedOutline,
        AppShadow(color: Color(argb: 0x5200_0000), blurRadius: 2, y: 1),
        AppShadow(color: Color(argb: 0x7300_0000), blurRadius: 14, spread: -8, y: 6),
        AppShadow(color: Color(argb: 0x9900_0000), blurRadius: 28, spread: -22, y: 14),
      ]
      : [
        AppShadow(color: Color(argb: 0x0D10_1828), blurRadius: 3),
        AppShadow(color: Color(argb: 0x0F10_1828), blurRadius: 8, y: 3),
      ]
  }

  /// 浮かせた面の外周の細い輪郭(0.5px のリング)。ダークのみ出す。
  var raisedOutline: AppShadow { AppShadow(color: Color(argb: 0x29FF_FFFF), blurRadius: 0, spread: 0.5) }

  /// 入力欄など沈めた面の内側の影(--well)。MobileWell が内側に描く。
  /// ダークの 2 つ目(blur 0・spread 1)は内側に引く 1px の輪郭。ライトは 1px の輪郭だけ。
  var wellShadow: [AppShadow] {
    isDark
      ? [
        AppShadow(color: Color(argb: 0x8000_0000), blurRadius: 2, y: 1),
        AppShadow(color: Color(argb: 0x0FFF_FFFF), blurRadius: 0, spread: 1),
      ]
      : [AppShadow(color: Color(argb: 0x4700_0000), blurRadius: 0, spread: 1)]
  }

  /// ヘッダの下端の線と影(--elevHead)。
  var headerShadow: [AppShadow] {
    isDark
      ? [
        AppShadow(color: Color(argb: 0x14FF_FFFF), blurRadius: 0, y: 1),
        AppShadow(color: Color(argb: 0x9900_0000), blurRadius: 12, spread: -12, y: 5),
      ]
      : [
        AppShadow(color: Color(argb: 0x1410_1828), blurRadius: 0, y: 1),
        AppShadow(color: Color(argb: 0x3310_1828), blurRadius: 12, spread: -13, y: 5),
      ]
  }

  /// 広告帯など画面下端に重なる面の上端の線と影(--elevUp)。headerShadow を上下反転した強さ。
  var bottomBarShadow: [AppShadow] {
    isDark
      ? [
        AppShadow(color: Color(argb: 0x14FF_FFFF), blurRadius: 0, y: -1),
        AppShadow(color: Color(argb: 0x9900_0000), blurRadius: 12, spread: -12, y: -5),
      ]
      : [
        AppShadow(color: Color(argb: 0x1410_1828), blurRadius: 0, y: -1),
        AppShadow(color: Color(argb: 0x3310_1828), blurRadius: 12, spread: -13, y: -5),
      ]
  }

  /// 主ボタンの影(--btnShadow の inset 以外)
  var buttonShadow: [AppShadow] {
    isDark
      ? [AppShadow(color: Color(argb: 0x5900_0000), blurRadius: 2, y: 1)]
      : [
        AppShadow(color: Color(argb: 0x0D10_1828), blurRadius: 1, y: 1),
        // 2 枚目はアクセントの色みを帯びた影(ブルーの元の値は #2678C8。淡い地の文字色で代える)。
        AppShadow(color: withAlpha(0x3D, tones.onSoftLight), blurRadius: 4, spread: -3, y: 1),
      ]
  }

  /// シート・ダイアログの後ろに敷く幕(デザインのオーバーレイ rgba(20,25,35,0.35))。
  var barrier: Color { Color(argb: 0x5914_1923) }

  /// 本文系の不透明度つき色(デザインの `--t70` 等)。ライトは黒ベース、ダークは白ベースで、
  /// `percent` はその不透明度(%)。
  func textAlpha(_ percent: Int) -> Color { alpha(percent) }

  /// ボーダー・区切り線の不透明度つき色(デザインの `--b10` 等)。本文系と同じ導出だが、意味が違うので呼び分ける。
  func borderAlpha(_ percent: Int) -> Color { alpha(percent) }

  private var tones: ThemeColor.Tones { theme.tones }

  /// 0xRRGGBB の不透明な色。
  private func opaque(_ rgb: UInt32) -> Color { Color(argb: 0xFF00_0000 | rgb) }

  /// 0xRRGGBB に不透明度(0x00〜0xFF)を付けた色。
  private func withAlpha(_ alpha: UInt32, _ rgb: UInt32) -> Color { Color(argb: alpha << 24 | rgb) }

  private func alpha(_ percent: Int) -> Color {
    (isDark ? Color.white : Color.black).opacity(Double(percent) / 100)
  }
}

extension EnvironmentValues {
  /// 今の iOS の配色。ルートで設定の appearance・テーマカラーから決めて配る。
  @Entry var palette: AppPalette = .light
}
