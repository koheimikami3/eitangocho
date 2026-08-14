import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  List<EjdictEntriesCompanion> entriesOf(Map<String, String> map) => [
    for (final e in map.entries)
      EjdictEntriesCompanion.insert(word: e.key, meanings: e.value),
  ];

  test('bulkInsert と count', () async {
    expect(await db.ejdictDao.count(), 0);

    await db.ejdictDao.bulkInsert(entriesOf({'apple': 'リンゴ', 'book': '本'}));

    expect(await db.ejdictDao.count(), 2);
  });

  test('lookup は収録語の訳を返し、未収録なら null', () async {
    await db.ejdictDao.bulkInsert(entriesOf({'apple': 'リンゴ'}));

    expect(await db.ejdictDao.lookup('apple'), 'リンゴ');
    expect(await db.ejdictDao.lookup('zzzzz'), isNull);
  });

  test('同一単語の再 bulkInsert は上書きする(insertOrReplace)', () async {
    await db.ejdictDao.bulkInsert(entriesOf({'apple': 'リンゴ'}));
    await db.ejdictDao.bulkInsert(entriesOf({'apple': '林檎'}));

    expect(await db.ejdictDao.count(), 1);
    expect(await db.ejdictDao.lookup('apple'), '林檎');
  });

  test('チャンクサイズ(5000)を超える件数も取り込める', () async {
    final many = {for (var i = 0; i < 5001; i++) 'word$i': '訳$i'};

    await db.ejdictDao.bulkInsert(entriesOf(many));

    expect(await db.ejdictDao.count(), 5001);
    expect(await db.ejdictDao.lookup('word5000'), '訳5000');
  });
}
