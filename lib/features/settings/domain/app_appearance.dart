import 'package:eitangocho/l10n/app_localizations.dart';

/// アプリの外観(配色)。iOS 版のみの設定で、macOS 版は常にライト。
///
/// OS の設定に追従する選択肢は用意しない(デザイン上もライト / ダークの
/// 2 択。追加するなら AppPalette ではなく ThemeMode を持つ形に変える)。
enum AppAppearance {
  light,
  dark;

  /// 設定画面の表示用ラベル
  String label(AppLocalizations l10n) => switch (this) {
    light => l10n.appearanceLight,
    dark => l10n.appearanceDark,
  };
}
