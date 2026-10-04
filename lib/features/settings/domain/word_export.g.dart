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
      deletions:
          (json['deletions'] as List<dynamic>?)
              ?.map(
                (e) => WordDeletionEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <WordDeletionEntry>[],
    );

Map<String, dynamic> _$WordExportFileToJson(_WordExportFile instance) =>
    <String, dynamic>{
      'version': instance.version,
      'exportedAt': const UtcDateTimeConverter().toJson(instance.exportedAt),
      'words': instance.words,
      'deletions': instance.deletions,
    };

_WordDeletionEntry _$WordDeletionEntryFromJson(Map<String, dynamic> json) =>
    _WordDeletionEntry(
      word: json['word'] as String,
      deletedAt: const UtcDateTimeConverter().fromJson(
        json['deletedAt'] as String,
      ),
    );

Map<String, dynamic> _$WordDeletionEntryToJson(_WordDeletionEntry instance) =>
    <String, dynamic>{
      'word': instance.word,
      'deletedAt': const UtcDateTimeConverter().toJson(instance.deletedAt),
    };

_WordExportEntry _$WordExportEntryFromJson(Map<String, dynamic> json) =>
    _WordExportEntry(
      word: json['word'] as String,
      meaning: json['japanese'] as String,
      ipa: json['ipa'] as String? ?? '',
      partsOfSpeech:
          (json['partsOfSpeech'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      exampleEn: json['exampleEn'] as String? ?? '',
      exampleTranslation: json['exampleJa'] as String? ?? '',
      translationLanguage: json['translationLanguage'] as String? ?? 'ja',
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
  'japanese': instance.meaning,
  'ipa': instance.ipa,
  'partsOfSpeech': instance.partsOfSpeech,
  'exampleEn': instance.exampleEn,
  'exampleJa': instance.exampleTranslation,
  'translationLanguage': instance.translationLanguage,
  'audioUrl': instance.audioUrl,
  'isLearned': instance.isLearned,
  'lastReviewedAt': const NullableUtcDateTimeConverter().toJson(
    instance.lastReviewedAt,
  ),
  'correctCount': instance.correctCount,
  'createdAt': const NullableUtcDateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const NullableUtcDateTimeConverter().toJson(instance.updatedAt),
};
