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

  test('recordQuizResult(knew:true) は correctCount+1・lastReviewedAt 付与し updatedAt は変えない', () async {
    final id = await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
    );
    final before = (await db.wordDao.watchAll().first).single;

    await Future<void>.delayed(const Duration(seconds: 1));
    await db.wordDao.recordQuizResult(id, knew: true);
    await db.wordDao.recordQuizResult(id, knew: true);

    final after = (await db.wordDao.watchAll().first).single;
    expect(after.correctCount, 2);
    expect(after.lastReviewedAt, isNotNull);
    // 実績記録では updatedAt を更新しない(内容編集専用に予約)。
    expect(after.updatedAt, before.updatedAt);
  });

  test('recordQuizResult(knew:false) は correctCount 据え置きで lastReviewedAt を更新する', () async {
    final id = await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
    );

    await db.wordDao.recordQuizResult(id, knew: false);

    final after = (await db.wordDao.watchAll().first).single;
    expect(after.correctCount, 0);
    expect(after.lastReviewedAt, isNotNull);
  });

  test('getAll は watchAll と同じ並び順で全件返す', () async {
    await db.wordDao.insertWord(
      const WordsCompanion(word: Value('first'), japanese: Value('一つ目')),
    );
    await db.wordDao.insertWord(
      const WordsCompanion(word: Value('second'), japanese: Value('二つ目')),
    );

    final words = await db.wordDao.getAll();
    expect(words.map((w) => w.word), ['second', 'first']);
  });

  test('importWords は渡された createdAt/updatedAt をそのまま書き込む', () async {
    final createdAt = DateTime.utc(2020, 1, 1);
    final updatedAt = DateTime.utc(2020, 1, 2);

    await db.wordDao.importWords(
      inserts: [
        WordsCompanion(
          word: const Value('serendipity'),
          japanese: const Value('偶然の幸運'),
          createdAt: Value(createdAt),
          updatedAt: Value(updatedAt),
        ),
      ],
      updates: [],
    );

    final words = await db.wordDao.getAll();
    // drift は DateTime を instant(epoch)で保存するため、UTC/ローカルの
    // 表現差はあっても同じ瞬間であることを確認する。
    expect(words.single.createdAt.isAtSameMomentAs(createdAt), isTrue);
    expect(words.single.updatedAt.isAtSameMomentAs(updatedAt), isTrue);
  });

  test('importWords は insert と update を両方適用する', () async {
    final id = await db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
    );
    final newUpdatedAt = DateTime.utc(2025, 1, 1);

    await db.wordDao.importWords(
      inserts: [
        WordsCompanion(
          word: const Value('banana'),
          japanese: const Value('バナナ'),
          createdAt: Value(DateTime.utc(2020, 1, 1)),
          updatedAt: Value(DateTime.utc(2020, 1, 1)),
        ),
      ],
      updates: [
        (
          id,
          WordsCompanion(
            japanese: const Value('リンゴ'),
            updatedAt: Value(newUpdatedAt),
          ),
        ),
      ],
    );

    final words = await db.wordDao.getAll();
    expect(words, hasLength(2));
    final apple = words.firstWhere((w) => w.word == 'apple');
    expect(apple.japanese, 'リンゴ');
    expect(apple.updatedAt.isAtSameMomentAs(newUpdatedAt), isTrue);
    expect(words.any((w) => w.word == 'banana'), isTrue);
  });
}
