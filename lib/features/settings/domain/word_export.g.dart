// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_export.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WordExportFile _$WordExportFileFromJson(Map<String, dynamic> json) =>
    _WordExportFile(
      version: (json['version'] as num).toInt(),
      exportedAt: const UtcDateTimeConverter().fromJson(
        json['exportedAt'] as String,
      ),
      words: (json['words'] as List<dynamic>)
          .map((e) => WordExportEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WordExportFileToJson(_WordExportFile instance) =>
    <String, dynamic>{
      'version': instance.version,
      'exportedAt': const UtcDateTimeConverter().toJson(instance.exportedAt),
      'words': instance.words,
    };

_WordExportEntry _$WordExportEntryFromJson(Map<String, dynamic> json) =>
    _WordExportEntry(
      word: json['word'] as String,
      japanese: json['japanese'] as String,
      ipa: json['ipa'] as String? ?? '',
      partsOfSpeech:
          (json['partsOfSpeech'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      exampleEn: json['exampleEn'] as String? ?? '',
      exampleJa: json['exampleJa'] as String? ?? '',
      audioUrl: json['audioUrl'] as String? ?? '',
      isLearned: json['isLearned'] as bool? ?? false,
      lastReviewedAt: const NullableUtcDateTimeConverter().fromJson(
        json['lastReviewedAt'] as String?,
      ),
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      createdAt: const NullableUtcDateTimeConverter().fromJson(
        json['createdAt'] as String?,
      ),
      updatedAt: const NullableUtcDateTimeConverter().fromJson(
        json['updatedAt'] as String?,
      ),
    );

Map<String, dynamic> _$WordExportEntryToJson(
  _WordExportEntry instance,
) => <String, dynamic>{
  'word': instance.word,
  'japanese': instance.japanese,
  'ipa': instance.ipa,
  'partsOfSpeech': instance.partsOfSpeech,
  'exampleEn': instance.exampleEn,
  'exampleJa': instance.exampleJa,
  'audioUrl': instance.audioUrl,
  'isLearned': instance.isLearned,
  'lastReviewedAt': const NullableUtcDateTimeConverter().toJson(
    instance.lastReviewedAt,
  ),
  'correctCount': instance.correctCount,
  'createdAt': const NullableUtcDateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const NullableUtcDateTimeConverter().toJson(instance.updatedAt),
};
