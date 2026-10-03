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

  /// 辞書 API の発音 mp3 URL。配信元が落ちていて再生に使えず、辞書ソースを
  /// kaikki に替えた際に取得もやめた(docs/design.md)。以後は常に空だが、
  /// 既存データと iCloud 同期の JSON フォーマットを壊さないため残している。
  TextColumn get audioUrl => text().withDefault(const Constant(''))();
  BoolColumn get isLearned => boolean().withDefault(const Constant(false))();

  /// クイズ実績(Phase 2 で更新開始。UI には出さない)。
  /// lastReviewedAt はクイズの出題順(selectQuizQuestions)に使う
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// 削除済み単語のログ(トゥームストーン)。iCloud 同期で削除を伝播させるために持つ。
///
/// スナップショット同期は「相手にあって自分に無い単語は追加」でマージするため、
/// 単に words から物理削除しただけでは、次の同期で相手のスナップショットから
/// その単語が復活してしまう(削除したのか相手が新規登録したのか区別できない)。
/// 削除した事実をここに残し、[deletedAt] と相手の updatedAt を比べて判断する。
///
/// words 側は物理削除のまま(論理削除にすると一覧・クイズ・検索の全クエリに
/// 除外条件を入れる必要があり、入れ忘れが即バグになる)。
class DeletedWords extends Table {
  /// 削除された単語。words.word と同じ表記で保持する
  /// (マージ時は WordExportService と同じく trim + 小文字化して突き合わせる)。
  TextColumn get word => text()();
  DateTimeColumn get deletedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {word};
}

/// EJDict-hand(英和辞書)。Phase 3 の初回起動時取込で投入する。
class EjdictEntries extends Table {
  TextColumn get word => text()();

  /// EJDict の訳文字列(複数語義は原文のまま保持)
  TextColumn get meanings => text()();

  @override
  Set<Column<Object>> get primaryKey => {word};
}

/// 辞書(kaikki)のレスポンスキャッシュ(成功時のみ保存し再フェッチしない)。
///
/// [responseJson] に入るのは生の JSONL ではなく、使う項目だけに絞って詰め直した
/// JSON 配列(KaikkiApiClient 参照)。生のままだと 1 語 20〜170KB ある。
class DictionaryCacheEntries extends Table {
  TextColumn get word => text()();
  TextColumn get responseJson => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {word};
}
