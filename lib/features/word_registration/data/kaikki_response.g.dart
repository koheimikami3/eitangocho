// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kaikki_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KaikkiEntry _$KaikkiEntryFromJson(Map<String, dynamic> json) => _KaikkiEntry(
  word: json['word'] as String?,
  pos: json['pos'] as String?,
  sounds:
      (json['sounds'] as List<dynamic>?)
          ?.map((e) => KaikkiSound.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <KaikkiSound>[],
  senses:
      (json['senses'] as List<dynamic>?)
          ?.map((e) => KaikkiSense.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <KaikkiSense>[],
);

Map<String, dynamic> _$KaikkiEntryToJson(_KaikkiEntry instance) =>
    <String, dynamic>{
      'word': instance.word,
      'pos': instance.pos,
      'sounds': instance.sounds,
      'senses': instance.senses,
    };

_KaikkiSound _$KaikkiSoundFromJson(Map<String, dynamic> json) => _KaikkiSound(
  ipa: json['ipa'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$KaikkiSoundToJson(_KaikkiSound instance) =>
    <String, dynamic>{'ipa': instance.ipa, 'tags': instance.tags};

_KaikkiSense _$KaikkiSenseFromJson(Map<String, dynamic> json) => _KaikkiSense(
  examples:
      (json['examples'] as List<dynamic>?)
          ?.map((e) => KaikkiExample.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <KaikkiExample>[],
);

Map<String, dynamic> _$KaikkiSenseToJson(_KaikkiSense instance) =>
    <String, dynamic>{'examples': instance.examples};

_KaikkiExample _$KaikkiExampleFromJson(Map<String, dynamic> json) =>
    _KaikkiExample(
      text: json['text'] as String?,
      type: json['type'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
    );

Map<String, dynamic> _$KaikkiExampleToJson(_KaikkiExample instance) =>
    <String, dynamic>{
      'text': instance.text,
      'type': instance.type,
      'tags': instance.tags,
    };
