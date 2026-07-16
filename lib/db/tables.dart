import 'package:drift/drift.dart';
import 'package:eitangocho/db/converters/part_of_speech_list_converter.dart';

/// 登録単語。updatedAt は将来の iCloud 同期の競合解決に使うため必ず更新する。
class Words extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text()();
  TextColumn get ipa => text().withDefault(const Constant(''))();

  /// 日本語訳(必須)
  TextColumn get japanese => text()();
  TextColumn get partsOfSpeech => text()
      .map(const PartOfSpeechListConverter())
      .withDefault(const Constant(''))();
  TextColumn get exampleEn => text().withDefault(const Constant(''))();
  TextColumn get exampleJa => text().withDefault(const Constant(''))();

  /// 辞書 API の発音 mp3 URL。空なら Google 翻訳リンクにフォールバック(Phase 3)
  TextColumn get audioUrl => text().withDefault(const Constant(''))();
  BoolColumn get isLearned => boolean().withDefault(const Constant(false))();

  /// クイズ実績(Phase 2 で更新開始。UI には出さない)
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// EJDict-hand(英和辞書)。Phase 3 の初回起動時取込で投入する。
class EjdictEntries extends Table {
  TextColumn get word => text()();

  /// EJDict の訳文字列(複数語義は原文のまま保持)
  TextColumn get meanings => text()();

  @override
  Set<Column<Object>> get primaryKey => {word};
}

/// Free Dictionary API のレスポンスキャッシュ(成功時のみ保存し再フェッチしない)。
/// Phase 3 で利用する。
class DictionaryCacheEntries extends Table {
  TextColumn get word => text()();
  TextColumn get responseJson => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {word};
}
