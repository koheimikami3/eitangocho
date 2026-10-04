import 'package:eitangocho/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// 品詞。DB には [name] を CSV 連結した文字列で保存する
/// (PartOfSpeechListConverter 参照)。
///
/// 宣言順は選択チップの並び順になるため、辞書や学校文法で一般的な
/// 名詞 → 動詞 → 形容詞 → 副詞 の順に合わせている(当初はプロトタイプの
/// ピル定義順で動詞が先頭だった)。保存は enum 名なので順を変えても
/// 既存データには影響しない。
///
/// ここが持つのはライトの配色で、ダークは AppPalette.posBadge が持つ
/// (macOS はライト固定のためこの定数を直接引く)。
///
/// バッジ色の決め方(当初はプロトタイプのピル定義をそのまま使っていた):
/// - 色相を 70 度以上離す。紫と青、赤と緑のように色覚特性で潰れる組には
///   さらに明度差を付ける(当初の紫と青は赤緑色覚でほぼ同色だった)
/// - 出番の多い品詞ほど淡く、まれな品詞ほど濃くする。一覧の大半を占める
///   名詞をいちばん静かな青に、いちばんまれな副詞を紫にしている
/// - 文字は 10px と小さいので、チップ背景に対して 4.5:1 以上を確保する
enum PartOfSpeech {
  noun(Color(0xFFE6F4FE), Color(0xFF026A9D)),
  verb(Color(0xFFE6F8E6), Color(0xFF097F23)),
  adjective(Color(0xFFFFEDEB), Color(0xFF90101A)),
  adverb(Color(0xFFF7EEFE), Color(0xFF67298C)),
  other(Color(0xFFECECEF), Color(0xFF68696B));

  const PartOfSpeech(this.badgeBackground, this.badgeForeground);

  /// 表示用ラベル
  String label(AppLocalizations l10n) => switch (this) {
    noun => l10n.posNoun,
    verb => l10n.posVerb,
    adjective => l10n.posAdjective,
    adverb => l10n.posAdverb,
    other => l10n.posOther,
  };

  /// ライトのバッジ背景色(ダークは AppPalette.posBadge)
  final Color badgeBackground;

  /// ライトのバッジ文字色(ダークは AppPalette.posBadge)
  final Color badgeForeground;
}

/// 複数品詞の表示用連結(例: 「名詞・動詞」)
extension PartOfSpeechListLabel on List<PartOfSpeech> {
  String joinedLabel(AppLocalizations l10n) =>
      map((p) => p.label(l10n)).join(l10n.posSeparator);
}

extension PartOfSpeechSelection on Set<PartOfSpeech> {
  /// 選択された品詞を保存順に並べる。
  ///
  /// [basedOn] にある品詞はその並びを保ち、新しく選ばれたものだけを enum の
  /// 宣言順で後ろに足す。[basedOn] には自動取得の結果(辞書が返した順 =
  /// その語の主用法が先頭)や、編集前の保存順を渡す。
  ///
  /// チップのタップ順をそのまま保存すると、付け外ししただけでその品詞が
  /// 末尾に回り、先頭の品詞で決まるバッジ色が変わってしまうため。
  List<PartOfSpeech> ordered({required List<PartOfSpeech> basedOn}) => [
    for (final pos in basedOn)
      if (contains(pos)) pos,
    for (final pos in PartOfSpeech.values)
      if (contains(pos) && !basedOn.contains(pos)) pos,
  ];
}
