import 'package:freezed_annotation/freezed_annotation.dart';

part 'kaikki_response.freezed.dart';
part 'kaikki_response.g.dart';

/// kaikki.org(wiktextract)の 1 エントリ = 1 品詞。
///
/// 実レスポンスでは sounds / senses / examples が丸ごと欠落する語があり、
/// sounds の要素も ipa を持つもの・audio だけのもの・rhymes だけのものが
/// 混在する。フィールドを required にしない(CLAUDE.md 規約)。
///
/// 使うのは word / pos / sounds / senses だけで、実際のレスポンスが持つ
/// etymology_text / forms / translations 等は読み飛ばす(translations は
/// 多言語化のときに使う。docs/design.md の将来構想)。
@freezed
abstract class KaikkiEntry with _$KaikkiEntry {
  const factory KaikkiEntry({
    String? word,
    String? pos,
    @Default(<KaikkiSound>[]) List<KaikkiSound> sounds,
    @Default(<KaikkiSense>[]) List<KaikkiSense> senses,
  }) = _KaikkiEntry;

  factory KaikkiEntry.fromJson(Map<String, dynamic> json) =>
      _$KaikkiEntryFromJson(json);
}

/// 発音。[ipa] は `/əbˈteɪn/`(音素表記)と `[ˈlɪɾ.ɚ.ə.t͡ʃɚ]`(異音表記)の
/// 両方が来る。[tags] は `US` / `General-American` / `Received-Pronunciation`
/// などの方言ラベル。
@freezed
abstract class KaikkiSound with _$KaikkiSound {
  const factory KaikkiSound({
    String? ipa,
    @Default(<String>[]) List<String> tags,
  }) = _KaikkiSound;

  factory KaikkiSound.fromJson(Map<String, dynamic> json) =>
      _$KaikkiSoundFromJson(json);
}

@freezed
abstract class KaikkiSense with _$KaikkiSense {
  const factory KaikkiSense({
    @Default(<KaikkiExample>[]) List<KaikkiExample> examples,
  }) = _KaikkiSense;

  factory KaikkiSense.fromJson(Map<String, dynamic> json) =>
      _$KaikkiSenseFromJson(json);
}

/// 例文。[type] は `example`(用例)と `quotation`(出典付きの文献引用)があり、
/// 後者は「[W]ith their magical words they [poets] bring forth ...(Leigh Hunt)」の
/// ような長い引用なので単語帳には使わない。[tags] に `collocation` が付くものは
/// `obtain permission` のような句の断片。
@freezed
abstract class KaikkiExample with _$KaikkiExample {
  const factory KaikkiExample({
    String? text,
    String? type,
    @Default(<String>[]) List<String> tags,
  }) = _KaikkiExample;

  factory KaikkiExample.fromJson(Map<String, dynamic> json) =>
      _$KaikkiExampleFromJson(json);
}
