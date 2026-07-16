import 'package:flutter/material.dart';

/// 品詞。DB には [name] を CSV 連結した文字列で保存する
/// (PartOfSpeechListConverter 参照)。
/// バッジ色はプロトタイプの PILLS 定義に準拠。
enum PartOfSpeech {
  verb('動詞', Color(0xFFE3EDFB), Color(0xFF1C56A8)),
  noun('名詞', Color(0xFFEEE7FA), Color(0xFF5B3BA8)),
  adjective('形容詞', Color(0xFFFBE7E7), Color(0xFFA83B3B)),
  adverb('副詞', Color(0xFFDFF1EC), Color(0xFF1F6F5C)),
  other('その他', Color(0xFFECECEF), Color(0xFF55555C));

  const PartOfSpeech(this.label, this.badgeBackground, this.badgeForeground);

  /// 表示用の日本語ラベル
  final String label;
  final Color badgeBackground;
  final Color badgeForeground;
}

/// 複数品詞の表示用連結(例: 「動詞・名詞」)
extension PartOfSpeechListLabel on List<PartOfSpeech> {
  String get joinedLabel => map((p) => p.label).join('・');
}
