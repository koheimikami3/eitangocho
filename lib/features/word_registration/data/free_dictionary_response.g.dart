// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'free_dictionary_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FreeDictionaryEntry _$FreeDictionaryEntryFromJson(Map<String, dynamic> json) =>
    _FreeDictionaryEntry(
      word: json['word'] as String?,
      phonetic: json['phonetic'] as String?,
      phonetics:
          (json['phonetics'] as List<dynamic>?)
              ?.map((e) => FdPhonetic.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <FdPhonetic>[],
      meanings:
          (json['meanings'] as List<dynamic>?)
              ?.map((e) => FdMeaning.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <FdMeaning>[],
    );

Map<String, dynamic> _$FreeDictionaryEntryToJson(
  _FreeDictionaryEntry instance,
) => <String, dynamic>{
  'word': instance.word,
  'phonetic': instance.phonetic,
  'phonetics': instance.phonetics,
  'meanings': instance.meanings,
};

_FdPhonetic _$FdPhoneticFromJson(Map<String, dynamic> json) =>
    _FdPhonetic(text: json['text'] as String?, audio: json['audio'] as String?);

Map<String, dynamic> _$FdPhoneticToJson(_FdPhonetic instance) =>
    <String, dynamic>{'text': instance.text, 'audio': instance.audio};

_FdMeaning _$FdMeaningFromJson(Map<String, dynamic> json) => _FdMeaning(
  partOfSpeech: json['partOfSpeech'] as String?,
  definitions:
      (json['definitions'] as List<dynamic>?)
          ?.map((e) => FdDefinition.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <FdDefinition>[],
);

Map<String, dynamic> _$FdMeaningToJson(_FdMeaning instance) =>
    <String, dynamic>{
      'partOfSpeech': instance.partOfSpeech,
      'definitions': instance.definitions,
    };

_FdDefinition _$FdDefinitionFromJson(Map<String, dynamic> json) =>
    _FdDefinition(
      definition: json['definition'] as String?,
      example: json['example'] as String?,
    );

Map<String, dynamic> _$FdDefinitionToJson(_FdDefinition instance) =>
    <String, dynamic>{
      'definition': instance.definition,
      'example': instance.example,
    };
