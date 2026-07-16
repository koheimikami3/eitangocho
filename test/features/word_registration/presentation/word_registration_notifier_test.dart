import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_notifier.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('英単語が空だとエラーになり保存されない', () async {
    final notifier = container.read(wordRegistrationProvider.notifier);

    final result = await notifier.save(
      word: '',
      ipa: '',
      japanese: 'りんご',
      exampleEn: '',
      exampleJa: '',
    );

    expect(result, isFalse);
    expect(
      container.read(wordRegistrationProvider).errorMessage,
      '英単語と日本語訳は必須です。',
    );
    expect(await db.wordDao.watchAll().first, isEmpty);
  });

  test('日本語訳が空だとエラーになり保存されない', () async {
    final notifier = container.read(wordRegistrationProvider.notifier);

    final result = await notifier.save(
      word: 'apple',
      ipa: '',
      japanese: '',
      exampleEn: '',
      exampleJa: '',
    );

    expect(result, isFalse);
    expect(
      container.read(wordRegistrationProvider).errorMessage,
      '英単語と日本語訳は必須です。',
    );
  });

  test('保存すると DAO に insert される', () async {
    final notifier = container.read(wordRegistrationProvider.notifier);

    final result = await notifier.save(
      word: ' apple ',
      ipa: '/ˈæpəl/',
      japanese: ' りんご ',
      exampleEn: 'An apple a day.',
      exampleJa: '1日1個のリンゴ。',
    );

    expect(result, isTrue);
    final words = await db.wordDao.watchAll().first;
    expect(words, hasLength(1));
    expect(words.single.word, 'apple');
    expect(words.single.japanese, 'りんご');
    expect(words.single.exampleEn, 'An apple a day.');
  });

  test('品詞を未選択のまま保存すると「その他」が補われる', () async {
    final notifier = container.read(wordRegistrationProvider.notifier);

    await notifier.save(
      word: 'apple',
      ipa: '',
      japanese: 'りんご',
      exampleEn: '',
      exampleJa: '',
    );

    final words = await db.wordDao.watchAll().first;
    expect(words.single.partsOfSpeech, [PartOfSpeech.other]);
  });

  test('品詞を選択した場合はそれが保存される', () async {
    final notifier = container.read(wordRegistrationProvider.notifier);
    notifier.togglePartOfSpeech(PartOfSpeech.noun);

    await notifier.save(
      word: 'apple',
      ipa: '',
      japanese: 'りんご',
      exampleEn: '',
      exampleJa: '',
    );

    final words = await db.wordDao.watchAll().first;
    expect(words.single.partsOfSpeech, [PartOfSpeech.noun]);
  });
}
