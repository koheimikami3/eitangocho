import 'dart:io';

import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/settings/data/word_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Swift 版(native/)が書き出した JSON を Flutter 版が読めることの確認。
///
/// 古い OS の端末は Flutter 版のまま同期し続けるので、Swift 版が書いた同期ファイルを
/// Flutter 版が読めることは恒久に要る(docs/design.md「データ・同期」)。
/// 固定データは Swift 版のテスト(WordExportServiceTests)が書き出しと一致することを確かめている。
void main() {
  const fixturePath =
      'native/Packages/EitangochoCore/Tests/EitangochoSyncTests/Fixtures/swift-export.json';

  late AppDatabase db;
  late WordExportService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = WordExportService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Swift 版が書き出したファイルを取り込める', () async {
    final json = File(fixturePath).readAsStringSync();

    final result = await service.importJson(json);

    expect(result.added, 2);
    expect(result.skipped, 0);

    final achieve = (await db.wordDao.findByWord('achieve'))!;
    expect(achieve.meaning, '實現');
    expect(achieve.ipa, '/əˈtʃiːv/');
    expect(achieve.partsOfSpeech, [PartOfSpeech.verb]);
    expect(achieve.exampleEn, 'She achieved her goal.');
    expect(achieve.exampleTranslation, '她實現了目標。');
    expect(achieve.translationLanguage, 'zh-Hant');
    expect(achieve.isLearned, isTrue);
    expect(achieve.correctCount, 3);
    expect(
      achieve.lastReviewedAt!.isAtSameMomentAs(DateTime.utc(2026, 10, 28, 9)),
      isTrue,
    );
    expect(achieve.createdAt.isAtSameMomentAs(DateTime.utc(2026, 10)), isTrue);
    expect(
      achieve.updatedAt.isAtSameMomentAs(DateTime.utc(2026, 10, 2, 12, 30, 15)),
      isTrue,
    );

    final phrase = (await db.wordDao.findByWord('run out of'))!;
    expect(phrase.lastReviewedAt, isNull);
    expect(phrase.partsOfSpeech, [PartOfSpeech.verb, PartOfSpeech.other]);

    final deletions = await db.wordDao.getDeletions();
    expect(deletions.single.word, 'apple');
    expect(
      deletions.single.deletedAt.isAtSameMomentAs(DateTime.utc(2026, 10, 3)),
      isTrue,
    );
  });
}
