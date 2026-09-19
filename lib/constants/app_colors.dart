import 'package:flutter/material.dart';

/// 配色定数。UI の正基準となる値(当初は HTML プロトタイプから抽出したが、
/// プロトタイプ廃止に伴い、これらの値自体が正基準)。
abstract final class AppColors {
  static const accent = Color(0xFF429FF0); // 主要アクション
  static const accentHover = Color(0xFF2B8EE0);
  static const cardHoverBorder = Color(0xA6429FF0); // rgba(66,159,240,0.65)

  // 発音ボタン(アクセント色を淡く敷いた上に濃い青の文字・アイコンを載せる)。
  static const accentSoft = Color(0x1A429FF0); // rgba(66,159,240,0.10)
  static const accentSoftHover = Color(0x33429FF0); // rgba(66,159,240,0.20)
  static const accentLine = Color(0x61429FF0); // rgba(66,159,240,0.38)
  static const accentLineHover = Color(0x99429FF0); // rgba(66,159,240,0.60)

  /// [accentSoft] の上に載せる文字・アイコン色。
  ///
  /// accent(#429FF0)では淡い地に対して 2.56:1 しか出ないため濃い青にする。
  /// デザインの #1E7FD6 も測ると 3.77:1(hover 3.43:1)で 12〜13px の文字には
  /// 足りないので、色相を保ったまま明度だけ下げた(通常 5.08:1 / hover 4.61:1)。
  /// macOS 専用の値。iOS は 1.6.0 の刷新で別の値を持つ(AppPalette.accentOnSoft)。
  static const accentOnSoft = Color(0xFF176AB4);
  static const danger = Color(0xFFC03030); // 削除系
  static const dangerHover = Color(0xFFA82828);
  static const dangerHoverBackground = Color(0xFFFDF2F2);
  static const textPrimary = Color(0xFF1D1D1F);
  static const textSecondary = Color(0x99000000); // rgba(0,0,0,0.6)
  static const textTertiary = Color(0x73000000); // rgba(0,0,0,0.45)
  static const textDisabled = Color(0x4D000000); // rgba(0,0,0,0.3)
  static const textMuted = Color(0x80000000); // rgba(0,0,0,0.5) 見出し・補助値
  static const textQuaternary = Color(0x66000000); // rgba(0,0,0,0.4) 補足文
  static const sidebarBackground = Color(0xFFF0F0F3);
  static const sidebarSelected = Color(0x17000000); // rgba(0,0,0,0.09)
  static const inputBackground = Color(0xFFF7F7F8);
  static const tableHeaderBackground = Color(0xFFFAFAFB);
  static const learnedRowBackground = Color(0xFFFAFAFB);
  static const rowHoverBackground = Color(0xFFF2F6FC);
  static const border = Color(0x14000000); // rgba(0,0,0,0.08)
  static const borderStrong = Color(0x24000000); // rgba(0,0,0,0.14)
  static const inputBorder = Color(0x26000000); // rgba(0,0,0,0.15)
  static const autoFillBadgeBackground = Color(0xFFE2F3E8); // 自動入力バッジ
  static const autoFillBadgeForeground = Color(0xFF1C7A3F);
  static const warningBannerBackground = Color(0xFFFDF6E3); // 辞書未収録バナー
  static const warningBannerBorder = Color(0xFFECD9A0);
  static const warningBannerForeground = Color(0xFF8A6D1A);
}
