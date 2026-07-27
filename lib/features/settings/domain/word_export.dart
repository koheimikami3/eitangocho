import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_export.freezed.dart';
part 'word_export.g.dart';

/// エクスポート/インポートの JSON トップレベル。
/// DB の `Word` を直接 toJson しない(スキーマ変更の影響を切り離すため)。
///
/// version 1 は `deletions` を持たない。読み込み側は v1 も受け付ける
/// (`deletions` は空として扱う)。
@freezed
abstract class WordExportFile with _$WordExportFile {
  const factory WordExportFile({
    required int version,
    @UtcDateTimeConverter() required DateTime exportedAt,
    required List<WordExportEntry> words,
    @Default(<WordDeletionEntry>[]) List<WordDeletionEntry> deletions,
  }) = _WordExportFile;

  factory WordExportFile.fromJson(Map<String, dynamic> json) =>
      _$WordExportFileFromJson(json);
}

/// 削除された 1 単語(トゥームストーン)。version 2 で追加。
/// これが無いと、片方の端末で削除した単語がもう片方の同期で復活してしまう。
@freezed
abstract class WordDeletionEntry with _$WordDeletionEntry {
  const factory WordDeletionEntry({
    required String word,
    @UtcDateTimeConverter() required DateTime deletedAt,
  }) = _WordDeletionEntry;

  factory WordDeletionEntry.fromJson(Map<String, dynamic> json) =>
      _$WordDeletionEntryFromJson(json);
}

/// エクスポート/インポート対象の 1 単語。
/// `id` は含めない(インポート先で採番し、単語文字列をマージキーにする)。
/// `partsOfSpeech` は enum name の配列だが、未知の値を捨てる復元(サービス層で実施)
/// に対応するため `List<String>` で受ける(`List<PartOfSpeech>` にすると
/// json_serializable が未知 enum 値でデシリアライズごと失敗する)。
@freezed
abstract class WordExportEntry with _$WordExportEntry {
  const factory WordExportEntry({
    required String word,
    required String japanese,
    @Default('') String ipa,
    @Default(<String>[]) List<String> partsOfSpeech,
    @Default('') String exampleEn,
    @Default('') String exampleJa,
    @Default('') String audioUrl,
    @Default(false) bool isLearned,
    @NullableUtcDateTimeConverter() DateTime? lastReviewedAt,
    @Default(0) int correctCount,
    @NullableUtcDateTimeConverter() DateTime? createdAt,
    @NullableUtcDateTimeConverter() DateTime? updatedAt,
  }) = _WordExportEntry;

  factory WordExportEntry.fromJson(Map<String, dynamic> json) =>
      _$WordExportEntryFromJson(json);
}

/// DateTime を UTC ISO8601 文字列でシリアライズする。
/// 素の `toIso8601String()` はローカル時刻のままだとゾーン情報を落とすため、
/// 必ず `toUtc()` してから変換する。
class UtcDateTimeConverter implements JsonConverter<DateTime, String> {
  const UtcDateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toUtc().toIso8601String();
}

/// [UtcDateTimeConverter] の nullable 版。
class NullableUtcDateTimeConverter
    implements JsonConverter<DateTime?, String?> {
  const NullableUtcDateTimeConverter();

  @override
  DateTime? fromJson(String? json) => json == null ? null : DateTime.parse(json);

  @override
  String? toJson(DateTime? object) => object?.toUtc().toIso8601String();
}
