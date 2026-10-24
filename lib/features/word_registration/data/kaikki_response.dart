import 'package:freezed_annotation/freezed_annotation.dart';

part 'kaikki_response.freezed.dart';
part 'kaikki_response.g.dart';

/// kaikki.org(wiktextract)の 1 エントリ = 1 品詞。
///
/// 実レスポンスでは sounds / senses / examples が丸ごと欠落する語があり、
/// sounds の要素も ipa を持つもの・audio だけのもの・rhymes だけのものが
/// 混在する。フィールドを required にしない(CLAUDE.md 規約)。
///
/// 使うのは word / pos / sounds / senses / translations だけで、実際の
/// レスポンスが持つ etymology_text / forms 等は読み飛ばす。
@freezed
abstract class KaikkiEntry with _$KaikkiEntry {
  const factory KaikkiEntry({
    String? word,
    String? pos,
    @Default(<KaikkiSound>[]) List<KaikkiSound> sounds,
    @Default(<KaikkiSense>[]) List<KaikkiSense> senses,
    @Default(<KaikkiTranslation>[]) List<KaikkiTranslation> translations,
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

/// 訳語(Wiktionary の translations 節)。
///
/// 生のレスポンスは全言語ぶんを持ち、`give up` では 1 品詞に 243 件来る。
/// キャッシュへ詰め直す時点で訳の言語の分(日本語 `ja`・北京語 `cmn`)だけに
/// 絞るので、パース後にこのリストへ残るのはそれらの訳語だけになる。
///
/// [word] は日本語なら漢字表記(`諦める`)で、かなは `alt` に入るが読みは
/// 使わないので読み飛ばす。中国語は `實現 /实现` のように繁体字と簡体字が
/// 並んで来る。同じ訳語が語義ごとに重複して来るため、使う側で畳む。
///
/// [lang] は言語名(`Chinese Mandarin` など)。北京語の訳語には `lang_code` が
/// `zh` で来るものがあり、それを見分けるためだけに読む。詰め直す時点で
/// `cmn` に揃えるので、キャッシュには書き出さない。
@freezed
abstract class KaikkiTranslation with _$KaikkiTranslation {
  const factory KaikkiTranslation({
    String? word,
    @JsonKey(name: 'lang_code') String? langCode,
    @JsonKey(includeToJson: false) String? lang,
  }) = _KaikkiTranslation;

  factory KaikkiTranslation.fromJson(Map<String, dynamic> json) =>
      _$KaikkiTranslationFromJson(json);
}

/// 語義。[glosses] は語義の文で、下位の語義では `[上位の語義, この語義]` の
/// ように上位から並ぶ(最後がこの語義そのもの)。[tags] は `obsolete` /
/// `archaic` / `form-of` などの注記で、英語の語義を選ぶときの除外に使う。
@freezed
abstract class KaikkiSense with _$KaikkiSense {
  const factory KaikkiSense({
    @Default(<String>[]) List<String> glosses,
    @Default(<String>[]) List<String> tags,
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
