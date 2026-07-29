import 'package:flutter/material.dart';

/// 品詞。DB には [name] を CSV 連結した文字列で保存する
/// (PartOfSpeechListConverter 参照)。
/// バッジ色はプロトタイプの PILLS 定義に準拠。
///
/// 宣言順は選択チップの並び順になるため、辞書や学校文法で一般的な
/// 名詞 → 動詞 → 形容詞 → 副詞 の順に合わせている(当初はプロトタイプの
/// ピル定義順で動詞が先頭だった)。保存は enum 名なので順を変えても
/// 既存データには影響しない。
enum PartOfSpeech {
  noun('名詞', Color(0xFFEEE7FA), Color(0xFF5B3BA8)),
  verb('動詞', Color(0xFFE3EDFB), Color(0xFF1C56A8)),
  adjective('形容詞', Color(0xFFFBE7E7), Color(0xFFA83B3B)),
  adverb('副詞', Color(0xFFDFF1EC), Color(0xFF1F6F5C)),
  other('その他', Color(0xFFECECEF), Color(0xFF55555C));

  const PartOfSpeech(this.label, this.badgeBackground, this.badgeForeground);

  /// 表示用の日本語ラベル
  final String label;
  final Color badgeBackground;
  final Color badgeForeground;
}

/// 複数品詞の表示用連結(例: 「名詞・動詞」)
extension PartOfSpeechListLabel on List<PartOfSpeech> {
  String get joinedLabel => map((p) => p.label).join('・');
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
