import 'package:flutter/material.dart';

/// macOS 版の配色。ライト / ダークの 2 セットを持つ(iOS 版は [AppPalette])。
///
/// ライトの値が UI の正基準(当初は HTML プロトタイプから抽出したが、
/// プロトタイプ廃止に伴い、これらの値自体が正基準)。
/// ダークの値は 2.11.1 で足したもので、iOS のダーク(AppPalette.dark)の
/// 対応する値を流用し、macOS にしか無いもの(サイドバー・ホバー・表の地)は
/// 同じ系統で新設した。
///
/// ウィジェットからは `context.colors.textPrimary` の形で引く。
@immutable
class AppColors {
  const AppColors._(this.brightness);

  final Brightness brightness;

  bool get isDark => brightness == Brightness.dark;

  static const light = AppColors._(Brightness.light);
  static const dark = AppColors._(Brightness.dark);

  static AppColors of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  @override
  bool operator ==(Object other) =>
      other is AppColors && other.brightness == brightness;

  @override
  int get hashCode => brightness.hashCode;

  // ---- アクセント ----

  /// 主要アクション。ライト / ダーク共通(アイコンと同色)。
  Color get accent => const Color(0xFF429FF0);
  Color get accentHover => const Color(0xFF2B8EE0);

  /// 主ボタンのホバー中のグラデーション(上 → 下)。通常時は iOS と同じ
  /// AppPalette.buttonGradient で、それを同じ向きのまま一段暗くしたもの。
  List<Color> get buttonGradientHover => [const Color(0xFF3F9CEF), accentHover];

  // 発音ボタン(アクセント色を淡く敷いた上に濃い青の文字・アイコンを載せる)。
  // ダークは地が暗いぶん濃く敷き、線は文字色と同じ色相で引く(iOS のダークと同じ)。
  Color get accentSoft => isDark
      ? const Color(0x38429FF0)
      : const Color(0x1A429FF0); // rgba(66,159,240,0.10)
  Color get accentSoftHover => isDark
      ? const Color(0x52429FF0)
      : const Color(0x33429FF0); // rgba(66,159,240,0.20)
  Color get accentLine => isDark
      ? const Color(0x737EC2FF)
      : const Color(0x61429FF0); // rgba(66,159,240,0.38)
  Color get accentLineHover => isDark
      ? const Color(0xA67EC2FF)
      : const Color(0x99429FF0); // rgba(66,159,240,0.60)

  /// [accentSoft] の上に載せる文字・アイコン色。
  ///
  /// ライトは accent(#429FF0)では淡い地に対して 2.56:1 しか出ないため濃い青にする。
  /// デザインの #1E7FD6 も測ると 3.77:1(hover 3.43:1)で 12〜13px の文字には
  /// 足りないので、色相を保ったまま明度だけ下げた(通常 5.08:1 / hover 4.61:1)。
  /// iOS のライトは 1.6.0 の刷新で別の値を持つ(AppPalette.accentOnSoft)。
  /// ダークは iOS と同じ値。
  Color get accentOnSoft =>
      isDark ? const Color(0xFF7EC2FF) : const Color(0xFF176AB4);

  // ---- 状態色 ----

  /// 削除系
  Color get danger =>
      isDark ? const Color(0xFFFF6B6B) : const Color(0xFFC03030);

  /// ホバー中の削除系。ライトは一段暗く、ダークは一段明るくして強める。
  Color get dangerHover =>
      isDark ? const Color(0xFFFF8F8F) : const Color(0xFFA82828);
  Color get dangerHoverBackground =>
      isDark ? const Color(0x1FFF6B6B) : const Color(0xFFFDF2F2);

  /// 完了の知らせ(登録しました 等)
  Color get success =>
      isDark ? const Color(0xFF6FD39A) : const Color(0xFF1C7A3F);

  // ---- 文字 ----

  Color get textPrimary =>
      isDark ? const Color(0xFFF5F5F7) : const Color(0xFF1D1D1F);
  Color get textSecondary => textAlpha(60);
  Color get textTertiary => textAlpha(45);
  Color get textDisabled => textAlpha(30);

  /// 見出し・補助値
  Color get textMuted => textAlpha(50);

  /// 補足文
  Color get textQuaternary => textAlpha(40);

  // ---- 面 ----

  /// カード・ツールバー・ダイアログなど地の上に乗る面。
  /// ダークは iOS の AppPalette.dark.surface と同じ。
  Color get surface => isDark ? const Color(0xFF242427) : Colors.white;

  /// 入力欄の地。ダークは面より暗くして沈んで見せる(iOS の wellBackground と同じ)。
  Color get inputFill => isDark ? const Color(0xFF131315) : Colors.white;

  /// ポップアップメニュー(右クリック・並び替え)の地。わずかに透ける。
  Color get menuBackground => isDark
      ? const Color.fromRGBO(44, 44, 48, 0.98)
      : const Color.fromRGBO(250, 250, 251, 0.98);

  Color get sidebarBackground =>
      isDark ? const Color(0xFF1B1B1E) : const Color(0xFFF0F0F3);
  Color get sidebarSelected => textAlpha(9);

  /// 設定の行などのホバーの地。
  Color get inputBackground =>
      isDark ? const Color(0xFF2E2E32) : const Color(0xFFF7F7F8);
  Color get tableHeaderBackground =>
      isDark ? const Color(0xFF1F1F22) : const Color(0xFFFAFAFB);
  Color get learnedRowBackground =>
      isDark ? const Color(0xFF1F1F22) : const Color(0xFFFAFAFB);

  /// ホバーの地は無彩色のグレーで統一する(2.2.0 で青み #F2F6FC から変更。
  /// 設定の行などのホバー [inputBackground] と同じ値)。
  Color get rowHoverBackground => inputBackground;

  // ---- 線 ----

  Color get border => borderAlpha(8);
  Color get borderStrong => borderAlpha(14);
  Color get inputBorder => borderAlpha(15);

  /// 未チェックのチェックボックス・ラジオの枠線。
  /// ダークは白 25% では地に溶けるため、iOS の checkOffBorder と同じ 45% にする。
  Color get controlBorder => isDark ? borderAlpha(45) : borderAlpha(25);

  // ---- バッジ・バナー ----

  /// 自動入力バッジ
  Color get autoFillBadgeBackground => isDark
      ? const Color(0x3830A060) // rgba(48,160,96,0.22)
      : const Color(0xFFE2F3E8);
  Color get autoFillBadgeForeground =>
      isDark ? const Color(0xFF6FD39A) : const Color(0xFF1C7A3F);

  /// 辞書未収録バナー
  Color get warningBannerBackground => isDark
      ? const Color(0x2EB49628) // rgba(180,150,40,0.18)
      : const Color(0xFFFDF6E3);
  Color get warningBannerBorder => isDark
      ? const Color(0x66C8AA3C) // rgba(200,170,60,0.4)
      : const Color(0xFFECD9A0);
  Color get warningBannerForeground =>
      isDark ? const Color(0xFFE8C766) : const Color(0xFF8A6D1A);

  /// 本文系の不透明度つき色。ライトは黒ベース、ダークは白ベースで、
  /// [percent] はその不透明度(%)。AppPalette.textAlpha と同じ導出。
  Color textAlpha(int percent) => _alpha(percent);

  /// ボーダー・区切り線の不透明度つき色。本文系と同じ導出だが、意味が違うので呼び分ける。
  Color borderAlpha(int percent) => _alpha(percent);

  Color _alpha(int percent) =>
      (isDark ? Colors.white : Colors.black).withValues(alpha: percent / 100);
}

/// ウィジェットから `context.colors.textPrimary` の形で配色を引くための糖衣。
///
/// AppPaletteContext と同じく ThemeData.brightness だけで決まるため、
/// ダイアログ・メニューなど別ルートの配下にも自動で行き渡る。
extension AppColorsContext on BuildContext {
  AppColors get colors => AppColors.of(Theme.of(this).brightness);
}
