import SwiftUI

/// macOS 版の配色。ライト / ダークの 2 セットを持つ(iOS 版の AppPalette は Phase 6 で移す)。
///
/// 値は Flutter 版の `lib/constants/app_colors.dart` をそのまま写したもので、
/// 見た目の正はこちら(Swift 版)と Flutter 版の両方で揃えておく。
/// ライト / ダークは OS の外観ではなく設定の `appearance` で決める。
///
/// 画面からは `@Environment(\.colors) private var colors` で引く。
nonisolated struct AppColors: Equatable, Sendable {
  let isDark: Bool

  static let light = AppColors(isDark: false)
  static let dark = AppColors(isDark: true)

  // MARK: - アクセント

  /// 主要アクション。ライト / ダーク共通(アイコンと同色)。
  var accent: Color { Color(argb: 0xFF42_9FF0) }
  var accentHover: Color { Color(argb: 0xFF2B_8EE0) }

  /// 主ボタンのグラデーション(上 → 下)。iOS の AppPalette.buttonGradient と同じ値。
  var buttonGradient: [Color] {
    isDark
      ? [Color(argb: 0xFF44_9DF0), Color(argb: 0xFF37_95E9)]
      : [Color(argb: 0xFF4D_A4F2), Color(argb: 0xFF3F_9CEF)]
  }

  /// 主ボタンのホバー中のグラデーション(上 → 下)。通常時の buttonGradient を
  /// 同じ向きのまま一段暗くしたもの。
  var buttonGradientHover: [Color] { [Color(argb: 0xFF3F_9CEF), accentHover] }

  /// 主ボタンの影(iOS の AppPalette.buttonShadow と同じ値)。
  var buttonShadow: [AppShadow] {
    isDark
      ? [AppShadow(color: Color(argb: 0x5900_0000), blurRadius: 2, y: 1)]
      : [
        AppShadow(color: Color(argb: 0x0D10_1828), blurRadius: 1, y: 1),
        AppShadow(color: Color(argb: 0x3D26_78C8), blurRadius: 4, spread: -3, y: 1),
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

  /// ダイアログの後ろに敷く幕(Flutter の showDialog の既定 Colors.black54)。
  var barrier: Color { Color(argb: 0x8A00_0000) }

  // 発音ボタン(アクセント色を淡く敷いた上に濃い青の文字・アイコンを載せる)。
  // ダークは地が暗いぶん濃く敷き、線は文字色と同じ色相で引く(iOS のダークと同じ)。
  var accentSoft: Color { isDark ? Color(argb: 0x3842_9FF0) : Color(argb: 0x1A42_9FF0) }
  var accentSoftHover: Color { isDark ? Color(argb: 0x5242_9FF0) : Color(argb: 0x3342_9FF0) }
  var accentLine: Color { isDark ? Color(argb: 0x737E_C2FF) : Color(argb: 0x6142_9FF0) }
  var accentLineHover: Color { isDark ? Color(argb: 0xA67E_C2FF) : Color(argb: 0x9942_9FF0) }

  /// accentSoft の上に載せる文字・アイコン色。
  ///
  /// ライトは accent(#429FF0)では淡い地に対して 2.56:1 しか出ないため濃い青にする
  /// (通常 5.08:1 / hover 4.61:1)。ダークは iOS と同じ値。
  var accentOnSoft: Color { isDark ? Color(argb: 0xFF7E_C2FF) : Color(argb: 0xFF17_6AB4) }

  // MARK: - 状態色

  /// 削除系
  var danger: Color { isDark ? Color(argb: 0xFFFF_6B6B) : Color(argb: 0xFFC0_3030) }

  /// ホバー中の削除系。ライトは一段暗く、ダークは一段明るくして強める。
  var dangerHover: Color { isDark ? Color(argb: 0xFFFF_8F8F) : Color(argb: 0xFFA8_2828) }
  var dangerHoverBackground: Color { isDark ? Color(argb: 0x1FFF_6B6B) : Color(argb: 0xFFFD_F2F2) }

  /// 淡い赤の地(クイズ結果の「忘れていた単語」の見出し。iOS の AppPalette.dangerSoft と同じ値)。
  var dangerSoft: Color { isDark ? Color(argb: 0x1FFF_6B6B) : Color(argb: 0x12C0_3030) }

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

  private func alpha(_ percent: Int) -> Color {
    (isDark ? Color.white : Color.black).opacity(Double(percent) / 100)
  }
}

extension EnvironmentValues {
  /// 今の配色。ルートで設定の appearance から決めて配る。
  @Entry var colors: AppColors = .light
}
