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

  test('save した JSON を find で取得できる。未キャッシュは null', () async {
    expect(await db.dictionaryCacheDao.find('apple'), isNull);

    await db.dictionaryCacheDao.save('apple', '[{"word":"apple"}]');

    expect(await db.dictionaryCacheDao.find('apple'), '[{"word":"apple"}]');
  });

  test('同一単語の save は上書きする(insertOrReplace)', () async {
    await db.dictionaryCacheDao.save('apple', '[1]');
    await db.dictionaryCacheDao.save('apple', '[2]');

    expect(await db.dictionaryCacheDao.find('apple'), '[2]');
  });
}
