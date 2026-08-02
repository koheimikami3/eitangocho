import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// v1 相当のスキーマ(deleted_words が無い状態)を素の sqlite3 で作る。
/// drift の schema dump は導入していないため、v1 の DDL を直接書き起こす。
void createV1Schema(Database raw) {
  raw
    ..execute('''
      CREATE TABLE words (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        ipa TEXT NOT NULL DEFAULT '',
        japanese TEXT NOT NULL,
        parts_of_speech TEXT NOT NULL DEFAULT '',
        example_en TEXT NOT NULL DEFAULT '',
        example_ja TEXT NOT NULL DEFAULT '',
        audio_url TEXT NOT NULL DEFAULT '',
        is_learned INTEGER NOT NULL DEFAULT 0 CHECK ("is_learned" IN (0, 1)),
        last_reviewed_at INTEGER,
        correct_count INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''')
    ..execute('''
      CREATE TABLE ejdict_entries (
        word TEXT NOT NULL,
        meanings TEXT NOT NULL,
        PRIMARY KEY (word)
      )
    ''')
    ..execute('''
      CREATE TABLE dictionary_cache_entries (
        word TEXT NOT NULL,
        response_json TEXT NOT NULL,
        fetched_at INTEGER NOT NULL,
        PRIMARY KEY (word)
      )
    ''')
    ..execute('PRAGMA user_version = 1');
}

/// v2 相当のスキーマ(v1 + deleted_words)。
void createV2Schema(Database raw) {
  createV1Schema(raw);
  raw
    ..execute('''
      CREATE TABLE deleted_words (
        word TEXT NOT NULL,
        deleted_at INTEGER NOT NULL,
        PRIMARY KEY (word)
      )
    ''')
    ..execute('PRAGMA user_version = 2');
}

void main() {
  test('v1 の DB を開くと deleted_words が追加され、既存の単語は残る', () async {
    final raw = sqlite3.openInMemory();
    createV1Schema(raw);
    raw.execute(
      'INSERT INTO words (word, japanese, created_at, updated_at) '
      "VALUES ('apple', 'りんご', 0, 0)",
    );

    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    addTearDown(db.close);

    // 何かクエリを投げた時点でマイグレーションが走る。
    final words = await db.wordDao.getAll();
    expect(words.single.word, 'apple');

    // 追加されたテーブルが使えること。
    final id = words.single.id;
    await db.wordDao.deleteWord(id);
    expect((await db.wordDao.getDeletions()).single.word, 'apple');

    expect(raw.userVersion, 3);
  });

  // 辞書ソースを Free Dictionary から kaikki に入れ替えた際の後始末。
  // 生レスポンスの形式が違うため、古いキャッシュは読めず捨てるしかない。
  test('v2 の DB を開くと辞書キャッシュだけが空になり、単語は残る', () async {
    final raw = sqlite3.openInMemory();
    createV2Schema(raw);
    raw
      ..execute(
        'INSERT INTO words (word, japanese, created_at, updated_at) '
        "VALUES ('apple', 'りんご', 0, 0)",
      )
      ..execute(
        'INSERT INTO dictionary_cache_entries (word, response_json, fetched_at) '
        """VALUES ('apple', '[{"word":"apple"}]', 0)""",
      );

    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    addTearDown(db.close);

    expect((await db.wordDao.getAll()).single.word, 'apple');
    expect(await db.dictionaryCacheDao.find('apple'), isNull);
    expect(raw.userVersion, 3);
  });

  test('新規 DB は最新スキーマで作られ、deleted_words が使える', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final id = await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
    );
    await db.wordDao.deleteWord(id);

    expect((await db.wordDao.getDeletions()).single.word, 'apple');
  });
}
