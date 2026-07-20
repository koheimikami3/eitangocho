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
  });

  final int added;
  final int updated;
  final int unchanged;
  final int skipped;
}

/// JSON エクスポート/インポートのロジック(DAO 呼び出し・JSON 変換)。
/// ファイル選択・読み書きは呼び出し側(presentation)の責務とし、
/// このクラスは文字列 ⇔ DB の変換のみを扱う(テスト容易性のため)。
class WordExportService {
  WordExportService(this._db);

  final AppDatabase _db;

  static const _currentVersion = 1;

  Future<String> exportJson() async {
    final rows = await _db.wordDao.getAll();
    final file = WordExportFile(
      version: _currentVersion,
      exportedAt: DateTime.now(),
      words: rows.map(_toEntry).toList(),
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
  /// - 全体を 1 トランザクションで実行する
  Future<ImportResult> importJson(String source) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const WordExportFormatException('JSON として読み込めませんでした。');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const WordExportFormatException('JSON の形式が不正です。');
    }
    if (decoded['version'] != _currentVersion) {
      throw const WordExportFormatException(
        '対応していないバージョンのファイルです。',
      );
    }
    final rawWords = decoded['words'];
    if (rawWords is! List) {
      throw const WordExportFormatException('JSON の形式が不正です。');
    }

    final existingRows = await _db.wordDao.getAll();
    final existingByKey = {
      for (final row in existingRows) _mergeKey(row.word): row,
    };

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
      final existing = existingByKey[_mergeKey(plan.word)];
      if (existing == null) {
        inserts.add(_toInsertCompanion(plan));
      } else if (plan.updatedAt.isAfter(existing.updatedAt)) {
        // word・createdAt は書かない(DB 側の表記・作成日時を維持する)。
        updates.add((existing.id, _toUpdateCompanion(plan)));
      } else {
        unchanged++;
      }
    }

    await _db.wordDao.importWords(inserts: inserts, updates: updates);

    return ImportResult(
      added: inserts.length,
      updated: updates.length,
      unchanged: unchanged,
      skipped: skipped,
    );
  }

  String _mergeKey(String word) => word.trim().toLowerCase();

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
