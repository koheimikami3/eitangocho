import 'package:eitangocho/l10n/app_localizations.dart';

/// 学習中カードの並び。iOS 版のみの設定で、macOS 版は独自のカードビューを持つ。
///
/// 既定は 2 列。1 列は 1 枚あたりの幅が広くなり、カードヘッダの組み方も変わる
/// (MobileWordCard 参照)。
enum LearningCardLayout {
  twoColumns(2),
  oneColumn(1);

  const LearningCardLayout(this.columns);

  /// 設定画面の表示用ラベル
  String label(AppLocalizations l10n) => switch (this) {
    twoColumns => l10n.layoutTwoColumns,
    oneColumn => l10n.layoutOneColumn,
  };

  /// 学習中グリッドの列数
  final int columns;
}
