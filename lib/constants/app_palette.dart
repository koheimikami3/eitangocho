import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:flutter/material.dart';

/// iOS 版の配色。ライト / ダークの 2 セットを持つ。
///
/// macOS 版は [AppColors] のライト固定配色をそのまま使い続ける
/// (ダーク対応は iOS のみ。macOS 1.0 のリリース済み外観を変えないため)。
/// 値は Claude Design の iOS プロトタイプ(`docs/design/ios/英単語帳アプリ iOS.dc.html`
/// の THEME_LIGHT / THEME_DARK / PILLS_LIGHT / PILLS_DARK)が正基準。
///
/// アクセント色だけはライト / ダークで共通(アイコンと同色の #429ff0)。
@immutable
class AppPalette {
  const AppPalette._({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceHeader,
    required this.tabBar,
    required this.text,
    required this.danger,
    required this.autoFillBadgeBackground,
    required this.autoFillBadgeForeground,
    required this.warningBannerBackground,
    required this.warningBannerForeground,
    required this.warningBannerBorder,
  });

  /// 画面の地の色(--bg)
  final Color background;

  /// カード・シート・ヘッダなど、地の上に乗る面(--surface)
  final Color surface;

  /// 入力欄・淡いボタンなど一段沈んだ面(--surface2)
  final Color surfaceAlt;

  /// リストのセクションヘッダなど(--surface3)
  final Color surfaceHeader;

  /// タブバー(半透明。背後がぼけている前提の色)(--tabbar)
  final Color tabBar;

  /// 本文色(--text)
  final Color text;

  final Color danger;
  final Color autoFillBadgeBackground;
  final Color autoFillBadgeForeground;
  final Color warningBannerBackground;
  final Color warningBannerForeground;
  final Color warningBannerBorder;

  final Brightness brightness;

  bool get isDark => brightness == Brightness.dark;

  /// アクセント色はライト / ダーク共通。
  Color get accent => AppColors.accent;

  static const light = AppPalette._(
    brightness: Brightness.light,
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF7F7F8),
    surfaceHeader: Color(0xFFFAFAFB),
    tabBar: Color(0xEBFAFAFB), // rgba(250,250,251,0.92)
    text: Color(0xFF1D1D1F),
    danger: Color(0xFFC03030),
    autoFillBadgeBackground: Color(0xFFE2F3E8),
    autoFillBadgeForeground: Color(0xFF1C7A3F),
    warningBannerBackground: Color(0xFFFDF6E3),
    warningBannerForeground: Color(0xFF8A6D1A),
    warningBannerBorder: Color(0xFFECD9A0),
  );

  static const dark = AppPalette._(
    brightness: Brightness.dark,
    background: Color(0xFF1C1C1E),
    surface: Color(0xFF2C2C2E),
    surfaceAlt: Color(0xFF3A3A3C),
    surfaceHeader: Color(0xFF242426),
    tabBar: Color(0xE61C1C1E), // rgba(28,28,30,0.9)
    text: Color(0xFFF5F5F7),
    danger: Color(0xFFFF6B6B),
    autoFillBadgeBackground: Color(0x3830A060), // rgba(48,160,96,0.22)
    autoFillBadgeForeground: Color(0xFF6FD39A),
    warningBannerBackground: Color(0x2EB49628), // rgba(180,150,40,0.18)
    warningBannerForeground: Color(0xFFE8C766),
    warningBannerBorder: Color(0x66C8AA3C), // rgba(200,170,60,0.4)
  );

  static AppPalette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  @override
  bool operator ==(Object other) =>
      other is AppPalette && other.brightness == brightness;

  @override
  int get hashCode => brightness.hashCode;

  /// 本文系の不透明度つき色(デザインの `--t70` 等に相当)。
  /// ライトは黒ベース、ダークは白ベースで、[percent] はその不透明度(%)。
  Color textAlpha(int percent) => _alpha(percent);

  /// ボーダー・区切り線の不透明度つき色(デザインの `--b10` 等に相当)。
  /// 本文系と同じ導出だが、意味が違うので呼び分ける。
  Color borderAlpha(int percent) => _alpha(percent);

  Color _alpha(int percent) =>
      (isDark ? Colors.white : Colors.black).withValues(alpha: percent / 100);

  /// 品詞バッジの配色(背景色, 文字色)。
  (Color, Color) posBadge(PartOfSpeech pos) => switch ((pos, isDark)) {
    (PartOfSpeech.verb, false) => (
      const Color(0xFFE3EDFB),
      const Color(0xFF1C56A8),
    ),
    (PartOfSpeech.verb, true) => (
      const Color(0x3D3C82DC), // rgba(60,130,220,0.24)
      const Color(0xFF9CC4F5),
    ),
    (PartOfSpeech.noun, false) => (
      const Color(0xFFEEE7FA),
      const Color(0xFF5B3BA8),
    ),
    (PartOfSpeech.noun, true) => (
      const Color(0x42966EDC), // rgba(150,110,220,0.26)
      const Color(0xFFC7AEF2),
    ),
    (PartOfSpeech.adjective, false) => (
      const Color(0xFFFBE7E7),
      const Color(0xFFA83B3B),
    ),
    (PartOfSpeech.adjective, true) => (
      const Color(0x3DD25A5A), // rgba(210,90,90,0.24)
      const Color(0xFFF0A6A6),
    ),
    (PartOfSpeech.adverb, false) => (
      const Color(0xFFDFF1EC),
      const Color(0xFF1F6F5C),
    ),
    (PartOfSpeech.adverb, true) => (
      const Color(0x3D32AA87), // rgba(50,170,135,0.24)
      const Color(0xFF84D8BE),
    ),
    (PartOfSpeech.other, false) => (
      const Color(0xFFECECEF),
      const Color(0x8C000000), // rgba(0,0,0,0.55)
    ),
    (PartOfSpeech.other, true) => (
      const Color(0x1FFFFFFF), // rgba(255,255,255,0.12)
      const Color(0x9EFFFFFF), // rgba(255,255,255,0.62)
    ),
  };
}

/// ウィジェットから `context.palette.surface` の形で配色を引くための糖衣。
///
/// パレットは Brightness だけで決まるため ThemeExtension は使わない。
/// MaterialApp の ThemeData.brightness を切り替えるだけで、ダイアログ・
/// ボトムシートなど別ルートの配下にも自動で行き渡る。
extension AppPaletteContext on BuildContext {
  AppPalette get palette => AppPalette.of(Theme.of(this).brightness);
}
