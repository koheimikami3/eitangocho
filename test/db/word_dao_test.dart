import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('insertWord は createdAt/updatedAt を付与し watchAll に反映される', () async {
    final id = await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
    );

    final words = await db.wordDao.watchAll().first;
    expect(words, hasLength(1));
    expect(words.single.id, id);
    expect(words.single.word, 'apple');
    expect(words.single.createdAt, isNotNull);
    expect(words.single.updatedAt, isNotNull);
  });

  test('watchAll は登録日時の新しい順(同時刻は id の新しい順)で返す', () async {
    await db.wordDao.insertWord(
      const WordsCompanion(word: Value('first'), japanese: Value('一つ目')),
    );
    await db.wordDao.insertWord(
      const WordsCompanion(word: Value('second'), japanese: Value('二つ目')),
    );

    final words = await db.wordDao.watchAll().first;
    expect(words.map((w) => w.word), ['second', 'first']);
  });

  test('updateWord はフィールドと updatedAt を更新する', () async {
    final id = await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
    );
    final before = await db.wordDao.watchAll().first;
    final updatedAtBefore = before.single.updatedAt;

    await Future<void>.delayed(const Duration(seconds: 1));
    await db.wordDao.updateWord(
      id,
      const WordsCompanion(
        japanese: Value('リンゴ'),
        partsOfSpeech: Value([PartOfSpeech.noun]),
      ),
    );

    final after = await db.wordDao.watchAll().first;
    expect(after.single.japanese, 'リンゴ');
    expect(after.single.partsOfSpeech, [PartOfSpeech.noun]);
    expect(after.single.updatedAt.isAfter(updatedAtBefore), isTrue);
  });

  test('deleteWord で行が消える', () async {
    final id = await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
    );

    await db.wordDao.deleteWord(id);

    final words = await db.wordDao.watchAll().first;
    expect(words, isEmpty);
  });

  test('setLearned で isLearned をトグルできる', () async {
    final id = await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
    );

    await db.wordDao.setLearned(id, isLearned: true);
    var words = await db.wordDao.watchAll().first;
    expect(words.single.isLearned, isTrue);

    await db.wordDao.setLearned(id, isLearned: false);
    words = await db.wordDao.watchAll().first;
    expect(words.single.isLearned, isFalse);
  });
}
