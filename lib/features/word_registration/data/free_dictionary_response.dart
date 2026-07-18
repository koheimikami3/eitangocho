import 'package:freezed_annotation/freezed_annotation.dart';

part 'free_dictionary_response.freezed.dart';
part 'free_dictionary_response.g.dart';

/// Free Dictionary API のレスポンスモデル。
/// 実レスポンスでは phonetic / phonetics[].text / phonetics[].audio /
/// definitions[].example 等が欠落しうるため、フィールドを required にしない
/// (安易な required は欠落時にデシリアライズごと失敗する。CLAUDE.md 規約)。
@freezed
abstract class FreeDictionaryEntry with _$FreeDictionaryEntry {
  const factory FreeDictionaryEntry({
    String? word,
    String? phonetic,
    @Default(<FdPhonetic>[]) List<FdPhonetic> phonetics,
    @Default(<FdMeaning>[]) List<FdMeaning> meanings,
  }) = _FreeDictionaryEntry;

  factory FreeDictionaryEntry.fromJson(Map<String, dynamic> json) =>
      _$FreeDictionaryEntryFromJson(json);
}

@freezed
abstract class FdPhonetic with _$FdPhonetic {
  const factory FdPhonetic({
    String? text,
    String? audio,
  }) = _FdPhonetic;

  factory FdPhonetic.fromJson(Map<String, dynamic> json) =>
      _$FdPhoneticFromJson(json);
}

@freezed
abstract class FdMeaning with _$FdMeaning {
  const factory FdMeaning({
    String? partOfSpeech,
    @Default(<FdDefinition>[]) List<FdDefinition> definitions,
  }) = _FdMeaning;

  factory FdMeaning.fromJson(Map<String, dynamic> json) =>
      _$FdMeaningFromJson(json);
}

@freezed
abstract class FdDefinition with _$FdDefinition {
  const factory FdDefinition({
    String? definition,
    String? example,
  }) = _FdDefinition;

  factory FdDefinition.fromJson(Map<String, dynamic> json) =>
      _$FdDefinitionFromJson(json);
}
