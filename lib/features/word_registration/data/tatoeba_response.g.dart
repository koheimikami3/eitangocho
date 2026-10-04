// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tatoeba_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TatoebaSearchResponse _$TatoebaSearchResponseFromJson(
  Map<String, dynamic> json,
) => _TatoebaSearchResponse(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => TatoebaSentence.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TatoebaSentence>[],
);

Map<String, dynamic> _$TatoebaSearchResponseToJson(
  _TatoebaSearchResponse instance,
) => <String, dynamic>{'data': instance.data};

_TatoebaSentence _$TatoebaSentenceFromJson(Map<String, dynamic> json) =>
    _TatoebaSentence(
      text: json['text'] as String?,
      translations:
          (json['translations'] as List<dynamic>?)
              ?.map(
                (e) => TatoebaTranslation.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <TatoebaTranslation>[],
    );

Map<String, dynamic> _$TatoebaSentenceToJson(_TatoebaSentence instance) =>
    <String, dynamic>{
      'text': instance.text,
      'translations': instance.translations,
    };

_TatoebaTranslation _$TatoebaTranslationFromJson(Map<String, dynamic> json) =>
    _TatoebaTranslation(
      lang: json['lang'] as String?,
      script: json['script'] as String?,
      text: json['text'] as String?,
    );

Map<String, dynamic> _$TatoebaTranslationToJson(_TatoebaTranslation instance) =>
    <String, dynamic>{
      'lang': instance.lang,
      'script': instance.script,
      'text': instance.text,
    };
