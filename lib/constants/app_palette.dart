import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:flutter/material.dart';

/// iOS 版の配色。ライト / ダークの 2 セットを持つ。
///
/// macOS 版は [AppColors] のライト固定配色をそのまま使い続ける
/// (ダーク対応は iOS のみ。macOS 1.0 のリリース済み外観を変えないため)。
/// 値は Claude Design の iOS プロトタイプ(THEME_LIGHT / THEME_DARK)を起点に、
/// 2.0.0 の「立体案」で面・本文色・影を更新したもの。立体案は輪郭を枠線ではなく
/// 影で出す: 地の上の面は [elevation] で浮かせ、入力欄などは [wellShadow]
/// (内側の影。描画は MobileWell)で沈める。品詞バッジの配色は 1.x から変えない。
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
    required this.wellBackground,
    required this.pressBackground,
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

  /// 一段沈んだ面(--surface2)
  final Color surfaceAlt;

  /// リストのセクションヘッダ・学習済みの行・広告帯など(--surface3)
  final Color surfaceHeader;

  /// タブバー(半透明。背後がぼけている前提の色)(--tabbar)
  final Color tabBar;

  /// 入力欄など内側の影で沈めた面(--wellBg)。ダークは面より暗くして沈んで見せる。
  final Color wellBackground;

  /// 押下中のカード・行の地(--pressBg)
  final Color pressBackground;

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

  /// 発音ボタンの淡い地(--acc-soft)。ダークは地が暗いぶん濃く敷く。
  ///
  /// ライトの値は macOS の [AppColors.accentSoft](10%)とは別に持つ
  /// (刷新案 A で iOS だけ 12% に上げたため)。
  Color get accentSoft =>
      isDark ? const Color(0x38429FF0) : const Color(0x1F429FF0);

  /// 白地・淡い青地に置く青文字・アイコン色(--acc-text)。
  /// 発音ボタン・購入を復元・戻るなど、押せる「文字」はすべてこの色にする。
  ///
  /// ライトの #1B78C2 は [accentSoft] の上で 4.14:1 と 4.5:1 に届かないが、
  /// 刷新案 A で [accent] と同じ色相に揃えるデザイン判断として採用した
  /// (白地の上では 4.65:1)。macOS は [AppColors.accentOnSoft] のまま。
  Color get accentOnSoft =>
      isDark ? const Color(0xFF7EC2FF) : const Color(0xFF1B78C2);

  /// 発音ボタンの枠線(--acc-line)。ダークは文字色と同じ色相で引く。
  Color get accentLine =>
      isDark ? const Color(0x737EC2FF) : const Color(0x6B429FF0);

  /// 購入済みで押せなくなった購入ボタンの地。
  Color get proButtonDone =>
      isDark ? const Color(0x1FFFFFFF) : const Color(0xFFECECEF);

  /// 購入済みの購入ボタンの文字色。ダークだけ 1 段明るいのはデザイン準拠。
  Color get proButtonDoneForeground => textAlpha(isDark ? 60 : 50);

  // ---- 線 ----

  /// リスト行・カード内・設定のセクション内の区切り線。
  /// 立体案は面を影で分けるぶん、区切り線は淡い黒 / 白 7% にした
  /// (デザインの --b05〜--b08 の中間)。
  Color get rowLine => borderAlpha(7);

  /// 未チェックのチェックボックス・ラジオの枠線。
  /// ライトは純黒ではなく青みの墨 rgba(18,22,32,0.38) で引く(1.6.0 から据え置き)。
  Color get checkOffBorder => isDark
      ? borderAlpha(45)
      : const Color(0xFF121620).withValues(alpha: 0.38);

  /// OFF のトグルの地。
  Color get toggleOff => isDark ? borderAlpha(22) : borderAlpha(18);

  // ---- 立体案の影 ----
  // 値はデザインの box-shadow をそのまま移したもの(Flutter の blurRadius は
  // CSS の blur と同じ尺度)。CSS にある面の上端の白いハイライト(inset)は、
  // 白地ではほぼ見えないため省く。

  /// 地の上に浮かせる面(カード・設定のセクション・クイズカード)の影(--elev)。
  /// 1 つ目はデザインではほぼ透明なリングだが、面の縁をはっきりさせるため
  /// [raisedOutline](押下時と同じ輪郭)に置き換えている(ユーザー判断)。
  List<BoxShadow> get elevation => isDark
      ? [
          raisedOutline,
          const BoxShadow(
            color: Color(0x52000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
          const BoxShadow(
            color: Color(0x73000000),
            blurRadius: 14,
            spreadRadius: -8,
            offset: Offset(0, 6),
          ),
          const BoxShadow(
            color: Color(0x99000000),
            blurRadius: 28,
            spreadRadius: -22,
            offset: Offset(0, 14),
          ),
        ]
      : [
          raisedOutline,
          const BoxShadow(
            color: Color(0x08101828),
            blurRadius: 1.5,
            offset: Offset(0, 1),
          ),
          const BoxShadow(
            color: Color(0x1A101828),
            blurRadius: 12,
            spreadRadius: -8,
            offset: Offset(0, 5),
          ),
          const BoxShadow(
            color: Color(0x24101828),
            blurRadius: 24,
            spreadRadius: -18,
            offset: Offset(0, 12),
          ),
        ];

  /// 浮かせた面の外周の細い輪郭(0.5px のリング)。常時・押下中とも出す。
  /// 濃さはデザインの押下時(12%)より少し濃い 16%(ユーザー判断)。
  BoxShadow get raisedOutline => BoxShadow(
    color: isDark ? const Color(0x29FFFFFF) : const Color(0x29101828),
    spreadRadius: 0.5,
  );

  /// 押下中の面の外側の影(--elevPress の inset 以外)。浮きを消して輪郭だけ残す。
  List<BoxShadow> get elevationPressed => isDark
      ? [raisedOutline]
      : [
          raisedOutline,
          const BoxShadow(
            color: Color(0x1A101828),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ];

  /// 押下中の面の内側の影(--elevPress の inset)。MobileWell で描く。
  List<BoxShadow> get pressedInsetShadow => [
    BoxShadow(
      color: isDark ? const Color(0xA6000000) : const Color(0x12101828),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  /// 入力欄など沈めた面の内側の影(--well)。MobileWell で描く。
  /// 2 つ目(blur 0・spread 1)は内側に引く 1px の輪郭。
  List<BoxShadow> get wellShadow => isDark
      ? const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
          BoxShadow(color: Color(0x0FFFFFFF), spreadRadius: 1),
        ]
      : const [
          BoxShadow(
            color: Color(0x0D101828),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
          BoxShadow(color: Color(0x0A101828), spreadRadius: 1),
        ];

  /// ヘッダの下端の線と影(--elevHead)。影はデザインより薄くしている
  /// (実機でヘッダが浮きすぎて見えたため。ユーザー判断)。
  List<BoxShadow> get headerShadow => isDark
      ? const [
          BoxShadow(color: Color(0x14FFFFFF), offset: Offset(0, 1)),
          BoxShadow(
            color: Color(0x99000000), // デザインは 0.9
            blurRadius: 12,
            spreadRadius: -12,
            offset: Offset(0, 5),
          ),
        ]
      : const [
          BoxShadow(color: Color(0x14101828), offset: Offset(0, 1)),
          BoxShadow(
            color: Color(0x33101828), // デザインは 0.32
            blurRadius: 12,
            spreadRadius: -13,
            offset: Offset(0, 5),
          ),
        ];

  /// タブバー・広告帯など画面下端に重なる面の上端の線と影(--elevUp)
  List<BoxShadow> get bottomBarShadow => isDark
      ? const [
          BoxShadow(color: Color(0x14FFFFFF), offset: Offset(0, -1)),
          BoxShadow(
            color: Color(0xE6000000),
            blurRadius: 20,
            spreadRadius: -18,
            offset: Offset(0, -10),
          ),
        ]
      : const [
          BoxShadow(color: Color(0x14101828), offset: Offset(0, -1)),
          BoxShadow(
            color: Color(0x8C101828),
            blurRadius: 20,
            spreadRadius: -18,
            offset: Offset(0, -10),
          ),
        ];

  /// 主ボタンの地(--btnGrad)。上から下へわずかに暗くして膨らみを出す。
  LinearGradient get buttonGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: isDark
        ? const [Color(0xFF449DF0), Color(0xFF3795E9)]
        : const [Color(0xFF4DA4F2), Color(0xFF3F9CEF)],
  );

  /// 主ボタンの影(--btnShadow の inset 以外)
  List<BoxShadow> get buttonShadow => isDark
      ? const [
          BoxShadow(
            color: Color(0x59000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x0D101828),
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x3D2678C8),
            blurRadius: 4,
            spreadRadius: -3,
            offset: Offset(0, 1),
          ),
        ];

  /// 削除ボタンの輪郭(--dangerLine)と押下中の地(--dangerSoft)
  Color get dangerLine =>
      isDark ? const Color(0x80FF6B6B) : const Color(0x73C03030);
  Color get dangerSoft =>
      isDark ? const Color(0x1FFF6B6B) : const Color(0x12C03030);

  static const light = AppPalette._(
    brightness: Brightness.light,
    background: Color(0xFFF4F5F8),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF4F5F8),
    surfaceHeader: Color(0xFFEFF1F5),
    tabBar: Color(0xEBFAFAFB), // rgba(250,250,251,0.92)
    wellBackground: Color(0xFFFAFBFC),
    pressBackground: Color(0xFFE8EBF1),
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
    background: Color(0xFF131315),
    surface: Color(0xFF242427),
    surfaceAlt: Color(0xFF1B1B1E),
    surfaceHeader: Color(0xFF1A1A1C),
    tabBar: Color(0xE61C1C1E), // rgba(28,28,30,0.9)
    wellBackground: Color(0xFF131315),
    pressBackground: Color(0xFF323238),
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
  ///
  /// ライトは enum が持つ定数をそのまま使う(macOS の PosBadge も同じ定数を
  /// 直接引くため、二重に持つと片方だけ直す事故になる)。
  /// ダークは同じ色相を明るい文字 + 半透明の地に振り直したもので、
  /// 色相の間隔・明度差・コントラストの根拠は PartOfSpeech のコメントを参照。
  (Color, Color) posBadge(PartOfSpeech pos) => isDark
      ? switch (pos) {
          PartOfSpeech.noun => (
            const Color(0x3D0A8FD1), // rgba(10,143,209,0.24)
            const Color(0xFFA4D8FE),
          ),
          PartOfSpeech.verb => (
            const Color(0x3D479C4D), // rgba(71,156,77,0.24)
            const Color(0xFFA1F7A3),
          ),
          PartOfSpeech.adjective => (
            const Color(0x3DCD605A), // rgba(205,96,90,0.24)
            const Color(0xFFFF958E),
          ),
          PartOfSpeech.adverb => (
            const Color(0x3DA06CC4), // rgba(160,108,196,0.24)
            const Color(0xFFD39DFA),
          ),
          PartOfSpeech.other => (
            const Color(0x1FFFFFFF), // rgba(255,255,255,0.12)
            const Color(0xFFB7B7BA),
          ),
        }
      : (pos.badgeBackground, pos.badgeForeground);
}

/// ウィジェットから `context.palette.surface` の形で配色を引くための糖衣。
///
/// パレットは Brightness だけで決まるため ThemeExtension は使わない。
/// MaterialApp の ThemeData.brightness を切り替えるだけで、ダイアログ・
/// ボトムシートなど別ルートの配下にも自動で行き渡る。
extension AppPaletteContext on BuildContext {
  AppPalette get palette => AppPalette.of(Theme.of(this).brightness);
}
