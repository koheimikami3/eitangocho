import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/settings/domain/word_export.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// エクスポート/インポート対象の JSON フォーマットが不正なときの例外
/// (未知の version・トップレベルの型不正・JSON 自体のパース失敗)。
class WordExportFormatException implements Exception {
  const WordExportFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// インポート結果の件数。
class ImportResult {
  const ImportResult({
    required this.added,
    required this.updated,
    required this.unchanged,
    required this.skipped,
    this.deleted = 0,
  });

  final int added;
  final int updated;
  final int unchanged;
  final int skipped;

  /// ファイル側の削除ログにより消した単語の件数。
  final int deleted;
}

/// JSON エクスポート/インポートのロジック(DAO 呼び出し・JSON 変換)。
/// ファイル選択・読み書きは呼び出し側(presentation)の責務とし、
/// このクラスは文字列 ⇔ DB の変換のみを扱う(テスト容易性のため)。
class WordExportService {
  WordExportService(this._db);

  final AppDatabase _db;

  /// 書き出すフォーマットのバージョン。
  /// v1 = words のみ / v2 = deletions(削除ログ)を追加。
  static const _currentVersion = 2;

  /// 読み込みを受け付けるバージョン。macOS 1.0 が書き出した v1 ファイルも
  /// 取り込めるようにする(v1 には deletions が無いので空として扱う)。
  static const _supportedVersions = {1, 2};

  Future<String> exportJson() async {
    final rows = await _db.wordDao.getAll();
    final deletions = await _db.wordDao.getDeletions();
    final file = WordExportFile(
      version: _currentVersion,
      exportedAt: DateTime.now(),
      words: rows.map(_toEntry).toList(),
      deletions: [
        for (final d in deletions)
          WordDeletionEntry(word: d.word, deletedAt: d.deletedAt),
      ],
    );
    return const JsonEncoder.withIndent('  ').convert(file.toJson());
  }

  WordExportEntry _toEntry(Word word) => WordExportEntry(
    word: word.word,
    japanese: word.japanese,
    ipa: word.ipa,
    partsOfSpeech: word.partsOfSpeech.map((p) => p.name).toList(),
    exampleEn: word.exampleEn,
    exampleJa: word.exampleJa,
    audioUrl: word.audioUrl,
    isLearned: word.isLearned,
    lastReviewedAt: word.lastReviewedAt,
    correctCount: word.correctCount,
    createdAt: word.createdAt,
    updatedAt: word.updatedAt,
  );

  /// マージ方式でインポートを適用する。
  /// - 単語文字列を trim + 小文字化したキーで既存レコードと照合する
  /// - 一致なし: 新規追加(ファイルの createdAt/updatedAt を維持)
  /// - 一致あり: ファイル側 updatedAt が新しいときだけ上書き(word 表記・
  ///   createdAt は DB 側を維持)。それ以外は変更なし扱い
  /// - word/japanese の欠落・型不正・空文字はスキップして続行する
  /// - ファイル内に同一単語が複数あれば、updatedAt が新しい方だけを採用する
  /// - 削除ログ(v2 の deletions)は、同じキーの単語がローカルにあり
  ///   deletedAt がその updatedAt より新しければ削除する。ローカルに無くても
  ///   ログ自体は取り込む(第 3 の端末へ伝播させるため)
  /// - 同じキーが words と deletions の両方にある場合はタイムスタンプの
  ///   新しい方を採用する
  /// - 全体を 1 トランザクションで実行する
  ///
  /// [respectLocalDeletions] はこちらの削除ログを尊重するかどうか。
  /// - 同期(SyncService)では true。自分が消した単語が、まだその削除を
  ///   知らないクラウドのスナップショットから復活するのを防ぐ
  /// - 手動インポート(バックアップの復元)では false。ファイルにある単語は
  ///   後から消していても復元する、というのがユーザーの期待に沿う
  Future<ImportResult> importJson(
    String source, {
    bool respectLocalDeletions = false,
  }) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const WordExportFormatException('JSON として読み込めませんでした。');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const WordExportFormatException('JSON の形式が不正です。');
    }
    if (!_supportedVersions.contains(decoded['version'])) {
      throw const WordExportFormatException(
        '対応していないバージョンのファイルです。',
      );
    }
    final rawWords = decoded['words'];
    if (rawWords is! List) {
      throw const WordExportFormatException('JSON の形式が不正です。');
    }
    // v1 には deletions が無い。型が違う場合も欠落と同じく空として扱い、
    // 単語本体の取り込みまで巻き添えで失敗させない。
    final rawDeletions = decoded['deletions'];
    final deletionsByKey = _parseDeletions(
      rawDeletions is List ? rawDeletions : const [],
    );

    final existingRows = await _db.wordDao.getAll();
    final existingByKey = {
      for (final row in existingRows) _mergeKey(row.word): row,
    };
    // こちらで削除済みの単語。ファイルにその単語が残っていても、削除の方が
    // 新しければ復活させない(削除直後の同期で、まだ削除を知らないクラウドの
    // スナップショットから自分の削除を打ち消してしまうのを防ぐ)。
    final localDeletions = respectLocalDeletions
        ? {
            for (final d in await _db.wordDao.getDeletions())
              _mergeKey(d.word): d.deletedAt,
          }
        : const <String, DateTime>{};

    final inserts = <WordsCompanion>[];
    final updates = <(int, WordsCompanion)>[];
    // ファイル内重複を先に解決するための、キーごとの採用候補。
    final plannedByKey = <String, _PlannedEntry>{};
    var skipped = 0;
    var unchanged = 0;

    for (final rawEntry in rawWords) {
      final WordExportEntry entry;
      try {
        if (rawEntry is! Map<String, dynamic>) {
          throw const FormatException();
        }
        entry = WordExportEntry.fromJson(rawEntry);
      } on Object {
        skipped++;
        continue;
      }

      final word = entry.word.trim();
      final japanese = entry.japanese.trim();
      if (word.isEmpty || japanese.isEmpty) {
        skipped++;
        continue;
      }

      final key = _mergeKey(word);
      final updatedAt =
          entry.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final createdAt = entry.createdAt ?? DateTime.now();

      final existingPlan = plannedByKey[key];
      if (existingPlan != null && !updatedAt.isAfter(existingPlan.updatedAt)) {
        // 既に採用済みの候補の方が新しい(または同時刻)ため、この行は捨てる。
        unchanged++;
        continue;
      }
      if (existingPlan != null) {
        // 直前に採用していた候補は、より新しいこの行に取って代わられる。
        unchanged++;
      }

      plannedByKey[key] = _PlannedEntry(
        word: word,
        japanese: japanese,
        entry: entry,
        updatedAt: updatedAt,
        createdAt: createdAt,
      );
    }

    for (final plan in plannedByKey.values) {
      final key = _mergeKey(plan.word);
      // 同じ単語が words と deletions の両方に載っていることがある
      // (別端末で削除された後、さらに別の端末で再登録された場合など)。
      // 新しい方の操作を採用する。ファイル側の削除ログとローカルの削除ログの
      // うち新しい方と、ファイル側の単語の updatedAt を比べる。
      final deletedAt = _laterOf(deletionsByKey[key], localDeletions[key]);
      if (deletedAt != null && !_wordWins(plan.updatedAt, deletedAt)) continue;

      final existing = existingByKey[key];
      if (existing == null) {
        inserts.add(_toInsertCompanion(plan));
      } else if (plan.updatedAt.isAfter(existing.updatedAt)) {
        // word・createdAt は書かない(DB 側の表記・作成日時を維持する)。
        updates.add((existing.id, _toUpdateCompanion(plan)));
      } else {
        unchanged++;
      }
    }

    // 削除ログの適用。削除後にこちらで編集していれば、その編集が勝つ
    // (同時刻は _wordWins のとおり削除の勝ち)。
    final deleteIds = <int>[];
    for (final MapEntry(key: key, value: deletedAt) in deletionsByKey.entries) {
      final existing = existingByKey[key];
      if (existing == null) continue;
      if (_wordWins(existing.updatedAt, deletedAt)) continue;
      // ファイル側の words に、削除より新しい同じ単語が載っている場合
      // (削除 → 別端末で再登録・再編集)。上の words ループが採用済みなので、
      // ここで消してしまうとその追加・更新が打ち消される。
      final planned = plannedByKey[key];
      if (planned != null && _wordWins(planned.updatedAt, deletedAt)) continue;
      deleteIds.add(existing.id);
    }

    await _db.wordDao.importWords(
      inserts: inserts,
      updates: updates,
      deleteIds: deleteIds,
      // ローカルに単語が無い分も含め、ログはすべて取り込む
      // (この端末を経由して第 3 の端末へ削除を伝播させるため)。
      deletions: [
        for (final MapEntry(key: key, value: deletedAt)
            in deletionsByKey.entries)
          DeletedWordsCompanion(
            word: Value(key),
            deletedAt: Value(deletedAt),
          ),
      ],
    );

    return ImportResult(
      deleted: deleteIds.length,
      added: inserts.length,
      updated: updates.length,
      unchanged: unchanged,
      skipped: skipped,
    );
  }

  String _mergeKey(String word) => word.trim().toLowerCase();

  /// 単語の更新が削除に勝つか。
  ///
  /// 同時刻のときは削除を優先する(単語を残さない)。drift の DateTime は
  /// 秒精度で保存されるため、「編集した直後に同じ秒で削除した」ケースで
  /// updatedAt と deletedAt が一致しうる。その並びでは削除が後に行われた
  /// 操作なので、引き分けは削除の勝ちにしないと消したはずの単語が
  /// 次の同期で復活してしまう。
  bool _wordWins(DateTime updatedAt, DateTime deletedAt) =>
      updatedAt.isAfter(deletedAt);

  /// 2 つの日時のうち新しい方(null は「無い」扱い)。
  DateTime? _laterOf(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }

  /// 削除ログをマージキー → deletedAt の Map に畳み込む。
  /// 同一単語が複数あれば新しい方を採る。単語本体と同じく、不正な行は
  /// 黙って捨ててインポート全体は続行する。
  Map<String, DateTime> _parseDeletions(List<Object?> raw) {
    final result = <String, DateTime>{};
    for (final rawEntry in raw) {
      final WordDeletionEntry entry;
      try {
        if (rawEntry is! Map<String, dynamic>) {
          throw const FormatException();
        }
        entry = WordDeletionEntry.fromJson(rawEntry);
      } on Object {
        continue;
      }

      final key = _mergeKey(entry.word);
      if (key.isEmpty) continue;

      final existing = result[key];
      if (existing == null || entry.deletedAt.isAfter(existing)) {
        result[key] = entry.deletedAt;
      }
    }
    return result;
  }

  List<PartOfSpeech> _partsOfSpeechOf(_PlannedEntry plan) {
    final byName = PartOfSpeech.values.asNameMap();
    return plan.entry.partsOfSpeech.map((name) => byName[name]).nonNulls.toList();
  }

  /// 新規追加用。word・createdAt もファイルの値をそのまま書く。
  WordsCompanion _toInsertCompanion(_PlannedEntry plan) {
    return WordsCompanion(
      word: Value(plan.word),
      japanese: Value(plan.japanese),
      ipa: Value(plan.entry.ipa),
      partsOfSpeech: Value(_partsOfSpeechOf(plan)),
      exampleEn: Value(plan.entry.exampleEn),
      exampleJa: Value(plan.entry.exampleJa),
      audioUrl: Value(plan.entry.audioUrl),
      isLearned: Value(plan.entry.isLearned),
      lastReviewedAt: Value(plan.entry.lastReviewedAt),
      correctCount: Value(plan.entry.correctCount),
      createdAt: Value(plan.createdAt),
      updatedAt: Value(plan.updatedAt),
    );
  }

  /// 既存レコードの更新用。word・createdAt は含めない
  /// (DB 側の表記・作成日時を維持するため)。
  WordsCompanion _toUpdateCompanion(_PlannedEntry plan) {
    return WordsCompanion(
      japanese: Value(plan.japanese),
      ipa: Value(plan.entry.ipa),
      partsOfSpeech: Value(_partsOfSpeechOf(plan)),
      exampleEn: Value(plan.entry.exampleEn),
      exampleJa: Value(plan.entry.exampleJa),
      audioUrl: Value(plan.entry.audioUrl),
      isLearned: Value(plan.entry.isLearned),
      lastReviewedAt: Value(plan.entry.lastReviewedAt),
      correctCount: Value(plan.entry.correctCount),
      updatedAt: Value(plan.updatedAt),
    );
  }
}

class _PlannedEntry {
  const _PlannedEntry({
    required this.word,
    required this.japanese,
    required this.entry,
    required this.updatedAt,
    required this.createdAt,
  });

  final String word;
  final String japanese;
  final WordExportEntry entry;
  final DateTime updatedAt;
  final DateTime createdAt;
}

/// riverpod_generator は drift 生成型を扱う @riverpod を InvalidTypeException で
/// 落とす既知バグがあるため、この Provider は手書きにする
/// (lib/features/word/data/word_list_provider.dart と同じ方針)。
final wordExportServiceProvider = Provider<WordExportService>(
  (ref) => WordExportService(ref.watch(databaseProvider)),
);
