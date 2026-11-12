import SwiftUI

/// macOS 版の配色。ライト / ダークの 2 セットを持つ(iOS 版の AppPalette は Phase 6 で移す)。
///
/// 値は Flutter 版の `lib/constants/app_colors.dart` をそのまま写したもので、
/// 見た目の正はこちら(Swift 版)と Flutter 版の両方で揃えておく。
/// ライト / ダークは OS の外観ではなく設定の `appearance` で決める。
///
/// アクセント系のトークン(accent・ホバー・accentSoft・accentLine・accentOnSoft・buttonGradient・buttonShadow)は
/// テーマカラー(`theme`)から作る(2.18.0。iOS の AppPalette と同じ値の表 ThemeColor.tones を使う)。
/// ブルーは今までの macOS の値のまま(iOS の刷新で変えた淡い地の文字色・影の色みは macOS には入れていない)。
///
/// 画面からは `@Environment(\.colors) private var colors` で引く。
nonisolated struct AppColors: Equatable, Sendable {
  let isDark: Bool
  var theme: ThemeColor = .free

  static let light = AppColors(isDark: false)
  static let dark = AppColors(isDark: true)

  // MARK: - アクセント

  /// 主要アクション。ブルーはライト / ダーク共通(アイコンと同色)。グラファイトだけダークで明るくする。
  var accent: Color { opaque(accentRGB) }

  /// ホバー中のアクセント。ブルーの元の値(#429FF0 → #2B8EE0)と同じく、彩度を上げて明度を下げる。
  var accentHover: Color {
    theme == .blue ? Color(argb: 0xFF2B_8EE0) : Self.hover(accentRGB)
  }

  /// 主ボタンのグラデーション(上 → 下)。iOS の AppPalette.buttonGradient と同じ値。
  var buttonGradient: [Color] {
    let (top, bottom) = isDark ? tones.gradientDark : tones.gradientLight
    return [opaque(top), opaque(bottom)]
  }

  /// 主ボタンのホバー中のグラデーション(上 → 下)。通常時の buttonGradient を
  /// 同じ向きのまま一段暗くしたもの(上はライトの下端の色、下はホバー中のアクセント)。
  var buttonGradientHover: [Color] { [opaque(tones.gradientLight.1), accentHover] }

  /// 主ボタンの影(iOS の AppPalette.buttonShadow と同じ値)。
  var buttonShadow: [AppShadow] {
    isDark
      ? [AppShadow(color: Color(argb: 0x5900_0000), blurRadius: 2, y: 1)]
      : [
        AppShadow(color: Color(argb: 0x0D10_1828), blurRadius: 1, y: 1),
        // 2 枚目はアクセントの色みを帯びた影。ブルーは元の値、ほかの色は淡い地の文字色で代える(iOS と同じ)。
        AppShadow(
          color: theme == .blue ? Color(argb: 0x3D26_78C8) : withAlpha(0x3D, tones.onSoftLight), blurRadius: 4,
          spread: -3, y: 1),
      ]
  }

  /// 地の上に浮かせる面(カード・面のボタン)の影。iOS の AppPalette.elevation と同じ値。
  ///
  /// ダークは影が地に溶けるので、白の細い輪郭(raisedOutline)を 1 枚目に敷く。
  /// ライトは四辺にごく近く回る淡い影と、下に落ちる影の 2 枚。どちらも青みの墨(#101828)で落とす。
  var elevation: [AppShadow] {
    isDark
      ? [
        AppShadow(color: Color(argb: 0x29FF_FFFF), blurRadius: 0, spread: 0.5),
        AppShadow(color: Color(argb: 0x5200_0000), blurRadius: 2, y: 1),
        AppShadow(color: Color(argb: 0x7300_0000), blurRadius: 14, spread: -8, y: 6),
        AppShadow(color: Color(argb: 0x9900_0000), blurRadius: 28, spread: -22, y: 14),
      ]
      : [
        AppShadow(color: Color(argb: 0x0D10_1828), blurRadius: 3),
        AppShadow(color: Color(argb: 0x0F10_1828), blurRadius: 8, y: 3),
      ]
  }

  /// Flutter の Material の elevation 3(ポップアップメニュー)の影。
  /// Material は影を elevation から描くので、同じ高さの Material Design の影の値で近づける。
  var menuShadow: [AppShadow] {
    [
      AppShadow(color: Color(argb: 0x3300_0000), blurRadius: 3, spread: -2, y: 3),
      AppShadow(color: Color(argb: 0x2400_0000), blurRadius: 4, y: 3),
      AppShadow(color: Color(argb: 0x1F00_0000), blurRadius: 8, y: 1),
    ]
  }

  /// Flutter の Material の elevation 6(スナックバー)の影。menuShadow と同じく Material Design の影の値で近づける。
  var snackBarShadow: [AppShadow] {
    [
      AppShadow(color: Color(argb: 0x3300_0000), blurRadius: 5, spread: -1, y: 3),
      AppShadow(color: Color(argb: 0x2400_0000), blurRadius: 10, y: 6),
      AppShadow(color: Color(argb: 0x1F00_0000), blurRadius: 18, y: 1),
    ]
  }

  /// ダイアログの後ろに敷く幕(Flutter の showDialog の既定 Colors.black54)。
  var barrier: Color { Color(argb: 0x8A00_0000) }

  // 発音ボタン(アクセント色を淡く敷いた上に濃い青の文字・アイコンを載せる)。
  // ダークは地が暗いぶん濃く敷き、線は文字色と同じ色相で引く(iOS のダークと同じ)。
  var accentSoft: Color { withAlpha(isDark ? 0x38 : 0x1A, accentRGB) }
  /// ホバー中の淡い地。ブルー以外の色は淡い地の文字色を 12% の地で 4.5:1 前後に合わせてあり(ThemeColor.tones)、
  /// 地を濃くすると 4.5:1 を割るため、地は変えずに線(accentLineHover)だけでホバーを示す。
  var accentSoftHover: Color {
    theme == .blue ? withAlpha(isDark ? 0x52 : 0x33, accentRGB) : accentSoft
  }
  var accentLine: Color { isDark ? withAlpha(0x73, tones.onSoftDark) : withAlpha(0x61, accentRGB) }
  var accentLineHover: Color { isDark ? withAlpha(0xA6, tones.onSoftDark) : withAlpha(0x99, accentRGB) }

  /// 淡いボタン(クイズ結果の「続ける」など)の地。accentSoft だと背景の薄いグレーとの差が小さく、ボタンに
  /// 見えないため一段濃く敷く(iOS の AppPalette.accentSoftButton と同じ値)。
  var accentSoftButton: Color { withAlpha(isDark ? 0x4D : 0x33, accentRGB) }

  /// accentSoft の上に載せる文字・アイコン色。
  ///
  /// ライトは accent(#429FF0)では淡い地に対して 2.56:1 しか出ないため濃い青にする
  /// (通常 5.08:1 / hover 4.61:1)。ダークとブルー以外の色は iOS と同じ値。
  var accentOnSoft: Color {
    if isDark { return opaque(tones.onSoftDark) }
    return theme == .blue ? Color(argb: 0xFF17_6AB4) : opaque(tones.onSoftLight)
  }

  /// 押せないボタンの地と文字(Pro の欄の購入ボタン・「購入済み」。iOS の AppPalette と同じ値)。
  var disabledButton: Color { isDark ? Color(argb: 0x1FFF_FFFF) : Color(argb: 0xFFEC_ECEF) }
  var disabledButtonForeground: Color { textAlpha(isDark ? 60 : 50) }

  // MARK: - 状態色

  /// 削除系
  var danger: Color { isDark ? Color(argb: 0xFFFF_6B6B) : Color(argb: 0xFFC0_3030) }

  /// ホバー中の削除系。ライトは一段暗く、ダークは一段明るくして強める。
  var dangerHover: Color { isDark ? Color(argb: 0xFFFF_8F8F) : Color(argb: 0xFFA8_2828) }
  var dangerHoverBackground: Color { isDark ? Color(argb: 0x1FFF_6B6B) : Color(argb: 0xFFFD_F2F2) }

  /// 淡い赤の地(クイズ結果の「忘れていた単語」の見出し。iOS の AppPalette.dangerSoft と同じ値)。
  var dangerSoft: Color { isDark ? Color(argb: 0x1FFF_6B6B) : Color(argb: 0x12C0_3030) }

  /// 赤の淡いボタン(クイズの「忘れていた」)の地。dangerSoft より一段濃く敷く(iOS の AppPalette と同じ値)。
  var dangerSoftButton: Color { isDark ? Color(argb: 0x33FF_6B6B) : Color(argb: 0x21C0_3030) }

  /// 完了の知らせ(登録しました 等)
  var success: Color { isDark ? Color(argb: 0xFF6F_D39A) : Color(argb: 0xFF1C_7A3F) }

  // MARK: - 文字

  var textPrimary: Color { isDark ? Color(argb: 0xFFF5_F5F7) : Color(argb: 0xFF1D_1D1F) }
  var textSecondary: Color { textAlpha(60) }
  var textTertiary: Color { textAlpha(45) }
  var textDisabled: Color { textAlpha(30) }

  /// 見出し・補助値
  var textMuted: Color { textAlpha(50) }

  /// 補足文
  var textQuaternary: Color { textAlpha(40) }

  /// Flutter 版で色を指定していない文字・入力欄の文字の色(Material 3 の onSurface。
  /// アクセント色から作られる配色の値をそのまま写した)。
  var materialOnSurface: Color { isDark ? Color(argb: 0xFFE0_E2E8) : Color(argb: 0xFF19_1C20) }

  /// Flutter 版の入力欄のヒントの色(Material 3 の onSurfaceVariant)。
  var materialOnSurfaceVariant: Color { isDark ? Color(argb: 0xFFC2_C7CF) : Color(argb: 0xFF42_474E) }

  /// Flutter 版のメニューの区切り線(Material 3 の outlineVariant)。
  var materialOutlineVariant: Color { isDark ? Color(argb: 0xFF42_474E) : Color(argb: 0xFFC2_C7CF) }

  /// Flutter 版のスライダーの目盛りの色(Material 3 の onPrimary と onSurfaceVariant。どちらも 38% で描く)。
  var materialOnPrimary: Color { isDark ? Color(argb: 0xFF00_3256) : .white }

  /// Flutter 版のスナックバーの地と文字(Material 3 の inverseSurface と onInverseSurface)。
  var materialInverseSurface: Color { isDark ? Color(argb: 0xFFE0_E2E8) : Color(argb: 0xFF2D_3135) }
  var materialOnInverseSurface: Color { isDark ? Color(argb: 0xFF2D_3135) : Color(argb: 0xFFEF_F0F7) }

  /// Flutter 版の InkWell のホバーの重ね色(ThemeData.hoverColor)。
  var materialHover: Color { isDark ? Color(argb: 0x0AFF_FFFF) : Color(argb: 0x0A00_0000) }

  // MARK: - 面

  /// アプリの地(Scaffold の背景。iOS の AppPalette.background と同じ値)。
  var background: Color { isDark ? Color(argb: 0xFF13_1315) : Color(argb: 0xFFF7_F8FA) }

  /// カード・ツールバー・ダイアログなど地の上に乗る面。
  /// ダークは iOS の AppPalette.dark.surface と同じ。
  var surface: Color { isDark ? Color(argb: 0xFF24_2427) : .white }

  /// 入力欄の地。ダークは面より暗くして沈んで見せる(iOS の wellBackground と同じ)。
  var inputFill: Color { isDark ? Color(argb: 0xFF13_1315) : .white }

  /// ポップアップメニュー(右クリック・並び替え)の地。わずかに透ける。
  var menuBackground: Color {
    isDark ? Color(r: 44, g: 44, b: 48, opacity: 0.98) : Color(r: 250, g: 250, b: 251, opacity: 0.98)
  }

  var sidebarBackground: Color { isDark ? Color(argb: 0xFF1B_1B1E) : Color(argb: 0xFFF0_F0F3) }
  var sidebarSelected: Color { textAlpha(9) }

  /// 設定の行などのホバーの地。
  var inputBackground: Color { isDark ? Color(argb: 0xFF2E_2E32) : Color(argb: 0xFFF7_F7F8) }
  var tableHeaderBackground: Color { isDark ? Color(argb: 0xFF1F_1F22) : Color(argb: 0xFFFA_FAFB) }
  var learnedRowBackground: Color { isDark ? Color(argb: 0xFF1F_1F22) : Color(argb: 0xFFFA_FAFB) }

  /// ホバーの地は無彩色のグレーで統一する(設定の行などのホバー inputBackground と同じ値)。
  var rowHoverBackground: Color { inputBackground }

  // MARK: - 線

  var border: Color { borderAlpha(8) }

  /// 影で浮かせた面の中の区切り線(クイズ結果の一覧。iOS の AppPalette.rowLine と同じ値)。
  var rowLine: Color { borderAlpha(7) }
  var borderStrong: Color { borderAlpha(14) }
  var inputBorder: Color { borderAlpha(15) }

  /// 未チェックのチェックボックス・ラジオの枠線。
  /// ダークは白 25% では地に溶けるため、iOS の checkOffBorder と同じ 45% にする。
  var controlBorder: Color { isDark ? borderAlpha(45) : borderAlpha(25) }

  // MARK: - バッジ・バナー

  /// 自動入力バッジ
  var autoFillBadgeBackground: Color { isDark ? Color(argb: 0x3830_A060) : Color(argb: 0xFFE2_F3E8) }
  var autoFillBadgeForeground: Color { isDark ? Color(argb: 0xFF6F_D39A) : Color(argb: 0xFF1C_7A3F) }

  /// 辞書未収録バナー
  var warningBannerBackground: Color { isDark ? Color(argb: 0x2EB4_9628) : Color(argb: 0xFFFD_F6E3) }
  var warningBannerBorder: Color { isDark ? Color(argb: 0x66C8_AA3C) : Color(argb: 0xFFEC_D9A0) }
  var warningBannerForeground: Color { isDark ? Color(argb: 0xFFE8_C766) : Color(argb: 0xFF8A_6D1A) }

  /// 本文系の不透明度つき色。ライトは黒ベース、ダークは白ベースで、
  /// `percent` はその不透明度(%)。AppPalette.textAlpha と同じ導出。
  func textAlpha(_ percent: Int) -> Color { alpha(percent) }

  /// ボーダー・区切り線の不透明度つき色。本文系と同じ導出だが、意味が違うので呼び分ける。
  func borderAlpha(_ percent: Int) -> Color { alpha(percent) }

  private var tones: ThemeColor.Tones { theme.tones }

  /// アクセント(0xRRGGBB)。
  private var accentRGB: UInt32 { isDark ? tones.accentDark : tones.accent }

  /// 0xRRGGBB の不透明な色。
  private func opaque(_ rgb: UInt32) -> Color { Color(argb: 0xFF00_0000 | rgb) }

  /// 0xRRGGBB に不透明度(0x00〜0xFF)を付けた色。
  private func withAlpha(_ alpha: UInt32, _ rgb: UInt32) -> Color { Color(argb: alpha << 24 | rgb) }

  /// ホバー中の色。ブルーの元の値(#429FF0 → #2B8EE0)の変え方に合わせ、彩度の残り(1 − 彩度)を 7 割に、
  /// 明度を 93.4% にする(色相は変えない)。
  private static func hover(_ rgb: UInt32) -> Color {
    let r = Double(rgb >> 16 & 0xFF) / 255
    let g = Double(rgb >> 8 & 0xFF) / 255
    let b = Double(rgb & 0xFF) / 255
    let maxValue = max(r, g, b)
    let delta = maxValue - min(r, g, b)
    var hue = 0.0
    if delta > 0 {
      if maxValue == r {
        hue = ((g - b) / delta).truncatingRemainder(dividingBy: 6)
      } else if maxValue == g {
        hue = (b - r) / delta + 2
      } else {
        hue = (r - g) / delta + 4
      }
      hue /= 6
      if hue < 0 { hue += 1 }
    }
    let saturation = maxValue == 0 ? 0 : delta / maxValue
    return Color(hue: hue, saturation: 1 - (1 - saturation) * 0.7, brightness: maxValue * 0.934)
  }

  private func alpha(_ percent: Int) -> Color {
    (isDark ? Color.white : Color.black).opacity(Double(percent) / 100)
  }
}

extension EnvironmentValues {
  /// 今の配色。ルートで設定の appearance から決めて配る。
  @Entry var colors: AppColors = .light
}
