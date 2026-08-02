import 'package:freezed_annotation/freezed_annotation.dart';

part 'tatoeba_response.freezed.dart';
part 'tatoeba_response.g.dart';

/// Tatoeba の文検索レスポンス。
@freezed
abstract class TatoebaSearchResponse with _$TatoebaSearchResponse {
  const factory TatoebaSearchResponse({
    @Default(<TatoebaSentence>[]) List<TatoebaSentence> data,
  }) = _TatoebaSearchResponse;

  factory TatoebaSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$TatoebaSearchResponseFromJson(json);
}

/// 検索にヒットした英文。[translations] は `trans:lang` を指定したときだけ入り、
/// 指定しないと null になる(フィールドを required にしない。CLAUDE.md 規約)。
@freezed
abstract class TatoebaSentence with _$TatoebaSentence {
  const factory TatoebaSentence({
    String? text,
    @Default(<TatoebaTranslation>[]) List<TatoebaTranslation> translations,
  }) = _TatoebaSentence;

  factory TatoebaSentence.fromJson(Map<String, dynamic> json) =>
      _$TatoebaSentenceFromJson(json);
}

@freezed
abstract class TatoebaTranslation with _$TatoebaTranslation {
  const factory TatoebaTranslation({
    String? lang,
    String? text,
  }) = _TatoebaTranslation;

  factory TatoebaTranslation.fromJson(Map<String, dynamic> json) =>
      _$TatoebaTranslationFromJson(json);
}
