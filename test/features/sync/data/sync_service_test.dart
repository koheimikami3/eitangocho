import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/settings/data/word_export_service.dart';
import 'package:eitangocho/features/sync/data/sync_service.dart';
import 'package:eitangocho/features/sync/domain/cloud_file_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// テスト用のインメモリ保管先。1 台の「クラウド」を複数の端末が共有する
/// 状況を作れるよう、内容と更新日時だけを持つ。
class InMemoryCloudFileStore implements CloudFileStore {
  String? contents;
  DateTime? modifiedAt;

  /// read の直後に差し込む処理。読み取りと書き戻しの間に他端末が割り込む
  /// 状況を作るのに使う(1 度だけ発火する)。
  Future<void> Function()? onAfterRead;

  int writeCount = 0;

  /// 未解決の競合版。resolveConflicts で消えた id は [resolvedIds] に残る。
  List<CloudConflict> conflicts = [];
  final resolvedIds = <String>[];

  /// readConflicts の直後に差し込む処理。取り込み後に新しい競合版が届く状況を
  /// 作るのに使う(1 度だけ発火する)。
  Future<void> Function()? onAfterReadConflicts;

  /// read / write で投げる失敗(最新化を待ちきれず見送った場合などの再現用)。
  Exception? readError;
  Exception? writeError;

  @override
  Future<String?> read() async {
    if (readError != null) throw readError!;
    final value = contents;
    final hook = onAfterRead;
    onAfterRead = null;
    await hook?.call();
    return value;
  }

  @override
  Future<DateTime?> lastModified() async => modifiedAt;

  @override
  Future<List<CloudConflict>> readConflicts() async {
    final value = [...conflicts];
    final hook = onAfterReadConflicts;
    onAfterReadConflicts = null;
    await hook?.call();
    return value;
  }

  @override
  Future<void> resolveConflicts(List<String> ids) async {
    conflicts = [
      for (final c in conflicts)
        if (!ids.contains(c.id)) c,
    ];
    resolvedIds.addAll(ids);
  }

  @override
  Future<void> write(String value) async {
    if (writeError != null) throw writeError!;
    contents = value;
    // 実際のファイルシステムと同じく、書くたびに更新日時が進む。
    modifiedAt = (modifiedAt ?? DateTime.utc(2026)).add(
      const Duration(seconds: 1),
    );
    writeCount++;
  }
}

void main() {
  late AppDatabase db;
  late InMemoryCloudFileStore store;
  late SyncService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    store = InMemoryCloudFileStore();
    service = SyncService(
      store: store,
      exportService: WordExportService(db),
      db: db,
    );
  });

  tearDown(() async => db.close());

  Future<int> addWord(String word, String meaning) => db.wordDao.insertWord(
    WordsCompanion(word: Value(word), meaning: Value(meaning)),
  );

  /// クラウド上の JSON に含まれる単語を取り出す。
  List<String> cloudWords() {
    if (store.contents == null) return [];
    final decoded = jsonDecode(store.contents!) as Map<String, dynamic>;
    return [
      for (final w in decoded['words'] as List)
        (w as Map<String, dynamic>)['word'] as String,
    ];
  }

  List<String> cloudDeletions() {
    if (store.contents == null) return [];
    final decoded = jsonDecode(store.contents!) as Map<String, dynamic>;
    return [
      for (final d in (decoded['deletions'] as List? ?? []))
        (d as Map<String, dynamic>)['word'] as String,
    ];
  }

  test('クラウドが空なら、ローカルの内容がそのまま書き出される', () async {
    await addWord('apple', 'りんご');

    final outcome = await service.sync();

    expect(outcome.hasChanges, isFalse);
    expect(cloudWords(), ['apple']);
  });

  test('クラウドにある単語がローカルへ取り込まれる', () async {
    // 1 台目が書いた状態を作る。
    await addWord('apple', 'りんご');
    await service.sync();
    final cloudSnapshot = store.contents;

    // 2 台目(空の DB)へ同じクラウドから取り込む。
    final db2 = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db2.close);
    final store2 = InMemoryCloudFileStore()
      ..contents = cloudSnapshot
      ..modifiedAt = DateTime.utc(2026);
    final service2 = SyncService(
      store: store2,
      exportService: WordExportService(db2),
      db: db2,
    );

    final outcome = await service2.sync();

    expect(outcome.added, 1);
    expect((await db2.wordDao.getAll()).single.word, 'apple');
  });

  test('両端末で同じ単語を編集したら updatedAt が新しい方が残る', () async {
    final id = await addWord('apple', 'ローカルの訳');
    final local = (await db.wordDao.getAll()).single;

    // クラウド側の方が新しい編集を持っている状況。
    store.contents = jsonEncode({
      'version': 2,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'words': [
        {
          'word': 'apple',
          'japanese': 'クラウドの訳',
          'updatedAt': local.updatedAt
              .add(const Duration(days: 1))
              .toUtc()
              .toIso8601String(),
        },
      ],
    });
    store.modifiedAt = DateTime.utc(2026);

    final outcome = await service.sync();

    expect(outcome.updated, 1);
    final after = (await db.wordDao.getAll()).single;
    expect(after.id, id);
    expect(after.meaning, 'クラウドの訳');
  });

  test('クラウドの削除ログでローカルの単語が消え、復活しない', () async {
    await addWord('apple', 'りんご');
    final local = (await db.wordDao.getAll()).single;

    store.contents = jsonEncode({
      'version': 2,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'words': <dynamic>[],
      'deletions': [
        {
          'word': 'apple',
          'deletedAt': local.updatedAt
              .add(const Duration(days: 1))
              .toUtc()
              .toIso8601String(),
        },
      ],
    });
    store.modifiedAt = DateTime.utc(2026);

    final outcome = await service.sync();

    expect(outcome.deleted, 1);
    expect(await db.wordDao.getAll(), isEmpty);
    // 書き戻したスナップショットにも削除ログが残るので、次の同期でも復活しない。
    expect(cloudWords(), isEmpty);
    expect(cloudDeletions(), ['apple']);

    await service.sync();
    expect(await db.wordDao.getAll(), isEmpty);
  });

  test('ローカルの削除がクラウドへ伝わる', () async {
    final id = await addWord('apple', 'りんご');
    await service.sync();
    expect(cloudWords(), ['apple']);

    await db.wordDao.deleteWord(id);
    await service.sync();

    expect(cloudWords(), isEmpty);
    expect(cloudDeletions(), ['apple']);
  });

  test('編集と同じ秒に削除しても復活しない', () async {
    // drift の DateTime は秒精度で保存されるため、編集直後に削除すると
    // updatedAt と deletedAt が同じ値になりうる。この引き分けで単語が
    // 復活しないこと(削除が勝つこと)を固定する。
    final id = await addWord('apple', 'りんご');
    await service.sync();

    final word = (await db.wordDao.getAll()).single;
    await db.wordDao.deleteWord(id);
    await (db.update(db.deletedWords)..where((t) => t.word.equals('apple')))
        .write(DeletedWordsCompanion(deletedAt: Value(word.updatedAt)));

    await service.sync();

    expect(await db.wordDao.getAll(), isEmpty);
    expect(cloudWords(), isEmpty);
  });

  test('手動インポート(バックアップ復元)では削除した単語も戻る', () async {
    // 同期と違い、こちらは「ファイルにあるものを復元する」のが期待される挙動。
    final id = await addWord('apple', 'りんご');
    final backup = await WordExportService(db).exportJson();
    await db.wordDao.deleteWord(id);

    final result = await WordExportService(db).importJson(backup);

    expect(result.added, 1);
    expect((await db.wordDao.getAll()).single.word, 'apple');
    // 復元した単語の削除ログは取り消され、次の同期で再び消えたりしない。
    expect(await db.wordDao.getDeletions(), isEmpty);
  });

  test('読み取り後に他端末が書き込んだら、やり直してその内容を取り込む', () async {
    await addWord('local', 'ローカル');

    // 読み取り直後に、別端末が 'remote' を含む内容を書いたことにする。
    store.onAfterRead = () async {
      store.contents = jsonEncode({
        'version': 2,
        'exportedAt': DateTime.now().toUtc().toIso8601String(),
        'words': [
          {'word': 'remote', 'japanese': 'リモート'},
        ],
      });
      store.modifiedAt = DateTime.utc(2026, 6);
    };

    await service.sync();

    // やり直しにより、他端末の 'remote' がローカルにもクラウドにも残る。
    final words = (await db.wordDao.getAll()).map((w) => w.word).toSet();
    expect(words, containsAll(<String>['local', 'remote']));
    expect(cloudWords(), containsAll(<String>['local', 'remote']));
  });

  test('保持期間を過ぎた削除ログは書き出し前に掃除される', () async {
    final id = await addWord('apple', 'りんご');
    await db.wordDao.deleteWord(id);
    // 181 日前に削除されたことにする。
    await (db.update(
      db.deletedWords,
    )..where((t) => t.word.equals('apple'))).write(
      DeletedWordsCompanion(
        deletedAt: Value(DateTime.now().subtract(const Duration(days: 181))),
      ),
    );

    await service.sync();

    expect(cloudDeletions(), isEmpty);
    expect(await db.wordDao.getDeletions(), isEmpty);
  });

  test('最新のデータを取得できずに読み取りを見送ったら、書き戻さない', () async {
    await addWord('apple', 'りんご');
    store.readError = const CloudNotReadyException();

    await expectLater(service.sync(), throwsA(isA<CloudNotReadyException>()));

    expect(store.writeCount, 0);
    expect(store.contents, isNull);
  });

  group('競合版', () {
    /// 単語 1 つだけを持つ同期ファイルの JSON。
    String snapshotWith(String word, String meaning, {DateTime? updatedAt}) =>
        jsonEncode({
          'version': 2,
          'exportedAt': DateTime.now().toUtc().toIso8601String(),
          'words': [
            {
              'word': word,
              'japanese': meaning,
              if (updatedAt != null)
                'updatedAt': updatedAt.toUtc().toIso8601String(),
            },
          ],
        });

    CloudConflict conflict(
      String id,
      String contents, {
      DateTime? modifiedAt,
    }) => CloudConflict(
      id: id,
      contents: contents,
      modifiedAt: modifiedAt ?? DateTime.now(),
    );

    test('競合版にだけある単語と、新しい編集が取り込まれる', () async {
      await addWord('apple', 'ローカルの訳');
      final local = (await db.wordDao.getAll()).single;
      store.conflicts = [
        conflict('a', snapshotWith('banana', 'バナナ')),
        conflict(
          'b',
          snapshotWith(
            'apple',
            '競合版の訳',
            updatedAt: local.updatedAt.add(const Duration(days: 1)),
          ),
        ),
      ];

      final outcome = await service.sync();

      expect(outcome.added, 1);
      expect(outcome.updated, 1);
      final words = {
        for (final w in await db.wordDao.getAll()) w.word: w.meaning,
      };
      expect(words, {'apple': '競合版の訳', 'banana': 'バナナ'});
      // 取り込んだ内容は書き戻したスナップショットにも載る。
      expect(cloudWords(), containsAll(<String>['apple', 'banana']));
    });

    test('競合版の古い編集では巻き戻らない', () async {
      await addWord('apple', 'ローカルの訳');
      final local = (await db.wordDao.getAll()).single;
      store.conflicts = [
        conflict(
          'a',
          snapshotWith(
            'apple',
            '古い訳',
            updatedAt: local.updatedAt.subtract(const Duration(days: 1)),
          ),
        ),
      ];

      await service.sync();

      expect((await db.wordDao.getAll()).single.meaning, 'ローカルの訳');
    });

    test('書き戻し後に、読み取った競合版だけが片付けられる', () async {
      store.conflicts = [conflict('a', snapshotWith('banana', 'バナナ'))];
      // 取り込みの後に、別の競合版が届いたことにする。
      store.onAfterReadConflicts = () async {
        store.conflicts = [
          ...store.conflicts,
          conflict('late', snapshotWith('cherry', 'さくらんぼ')),
        ];
      };

      await service.sync();

      expect(store.resolvedIds, ['a']);
      expect(store.conflicts.map((c) => c.id), ['late']);
    });

    test('書き戻しに失敗したら競合版は片付けない', () async {
      store.conflicts = [conflict('a', snapshotWith('banana', 'バナナ'))];
      store.writeError = const CloudNotReadyException();

      await expectLater(service.sync(), throwsA(isA<CloudNotReadyException>()));

      expect(store.resolvedIds, isEmpty);
      expect(store.conflicts, hasLength(1));
    });

    test('削除ログの保持期間より古い競合版は、取り込まずに片付ける', () async {
      store.conflicts = [
        conflict(
          'old',
          snapshotWith('banana', 'バナナ'),
          modifiedAt: DateTime.now().subtract(const Duration(days: 181)),
        ),
      ];

      final outcome = await service.sync();

      expect(outcome.added, 0);
      expect(await db.wordDao.getAll(), isEmpty);
      expect(store.resolvedIds, ['old']);
    });

    test('壊れた競合版は取り込まずに片付け、同期は続ける', () async {
      store.conflicts = [
        conflict('broken', '{not json'),
        conflict('ok', snapshotWith('banana', 'バナナ')),
      ];

      await service.sync();

      expect((await db.wordDao.getAll()).single.word, 'banana');
      expect(store.resolvedIds, containsAll(<String>['broken', 'ok']));
    });
  });
}
