import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/word_registration/data/dictionary_word_info_provider.dart';
import 'package:eitangocho/features/word_registration/domain/registration_step.dart';
import 'package:eitangocho/features/word_registration/domain/word_info.dart';
import 'package:eitangocho/features/word_registration/domain/word_info_exception.dart';
import 'package:eitangocho/features/word_registration/domain/word_info_provider.dart';
import 'package:eitangocho/features/word_registration/presentation/word_registration_notifier.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// autoFill のテスト用フェイク(実 API を呼ばない)。
class _FakeWordInfoProvider implements WordInfoProvider {
  _FakeWordInfoProvider(this._handler);

  final Future<WordInfo?> Function(String word) _handler;

  @override
  Future<WordInfo?> fetch(String word) => _handler(word);
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  ProviderContainer buildContainer({WordInfoProvider? wordInfoProvider}) {
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        if (wordInfoProvider != null)
          wordInfoProviderProvider.overrideWithValue(wordInfoProvider),
      ],
    );
    // 自動破棄 Provider が autoFill の await 中に破棄されないよう購読しておく
    final subscription = c.listen(wordRegistrationProvider, (_, _) {});
    addTearDown(subscription.close);
    return c;
  }

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('英単語が空だとエラーになり保存されない', () async {
    container = buildContainer();
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
    container = buildContainer();
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
    container = buildContainer();
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
    container = buildContainer();
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
    container = buildContainer();
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

  test('手動で選んだ品詞はタップ順ではなく規定順で保存される', () async {
    container = buildContainer();
    final notifier = container.read(wordRegistrationProvider.notifier);
    // 形容詞 → 名詞 の順にタップする。
    notifier
      ..togglePartOfSpeech(PartOfSpeech.adjective)
      ..togglePartOfSpeech(PartOfSpeech.noun);

    await notifier.save(
      word: 'light',
      ipa: '',
      japanese: '光',
      exampleEn: '',
      exampleJa: '',
    );

    final words = await db.wordDao.watchAll().first;
    // 先頭の品詞でバッジ色が決まるため、タップ順に引きずられないこと。
    expect(words.single.partsOfSpeech, [
      PartOfSpeech.noun,
      PartOfSpeech.adjective,
    ]);
  });

  test('wordInfoProvider は keepAlive で、リスナー無しの read 後もイベントループを'
      '跨いで破棄されない(fetch 途中に http.Client が close される回帰を防ぐ)', () async {
    // フェイクを渡さず実 wordInfoProvider を使う(内部で http.Client を保持する)。
    container = buildContainer();

    final first = container.read(wordInfoProviderProvider);
    // autoDispose だとリスナーの無い read 後、イベントループ一巡で破棄され、
    // onDispose の httpClient.close() が走ってしまう。keepAlive なら破棄されない。
    await Future<void>.delayed(Duration.zero);
    final second = container.read(wordInfoProviderProvider);

    // 破棄→再生成が起きていなければ同一インスタンス
    expect(identical(first, second), isTrue);
  });

  group('autoFill', () {
    const fetchedInfo = WordInfo(
      word: 'serendipity',
      ipa: '/ˌsɛ.ɹən.ˈdɪ.pɪ.ti/',
      partsOfSpeech: [PartOfSpeech.noun],
      japanese: '思わぬ発見',
      exampleEn: 'A lucky find.',
      exampleJa: '幸運な発見。',
      audioUrl: 'https://example.com/a.mp3',
    );

    test('空入力はエラーを表示し input に留まる', () async {
      container = buildContainer(
        wordInfoProvider: _FakeWordInfoProvider((_) async => fetchedInfo),
      );

      await container.read(wordRegistrationProvider.notifier).autoFill('   ');

      final state = container.read(wordRegistrationProvider);
      expect(state.step, RegistrationStep.input);
      expect(state.errorMessage, '英単語を入力してください。');
    });

    test('成功すると form へ遷移し fetched と品詞が反映される', () async {
      container = buildContainer(
        wordInfoProvider: _FakeWordInfoProvider((_) async => fetchedInfo),
      );

      await container
          .read(wordRegistrationProvider.notifier)
          .autoFill('serendipity');

      final state = container.read(wordRegistrationProvider);
      expect(state.step, RegistrationStep.form);
      expect(state.fetched, fetchedInfo);
      expect(state.notFound, isFalse);
      expect(state.selectedPartsOfSpeech, {PartOfSpeech.noun});
      expect(state.translationFailed, isFalse);
    });

    test('未収録(null)なら form へ遷移し notFound が立つ', () async {
      container = buildContainer(
        wordInfoProvider: _FakeWordInfoProvider((_) async => null),
      );

      await container.read(wordRegistrationProvider.notifier).autoFill('zzzzz');

      final state = container.read(wordRegistrationProvider);
      expect(state.step, RegistrationStep.form);
      expect(state.notFound, isTrue);
      expect(state.fetched, isNull);
    });

    test('WordInfoException なら input に戻しエラーを表示する', () async {
      container = buildContainer(
        wordInfoProvider: _FakeWordInfoProvider(
          (_) async => throw const WordInfoException('offline'),
        ),
      );

      await container.read(wordRegistrationProvider.notifier).autoFill('apple');

      final state = container.read(wordRegistrationProvider);
      expect(state.step, RegistrationStep.input);
      expect(state.errorMessage, '辞書データの取得に失敗しました。通信環境を確認してください。');
    });

    // DeepL のキーは条件に含めない。設定 UI を隠したいま、キーを条件にすると
    // 辞書側の例文を採って和訳が無い場合に警告が一切出なくなる。
    test('英例文ありなのに和訳が空なら translationFailed(DeepL キーは無関係)', () async {
      container = buildContainer(
        wordInfoProvider: _FakeWordInfoProvider(
          (_) async => fetchedInfo.copyWith(exampleJa: ''),
        ),
      );

      await container
          .read(wordRegistrationProvider.notifier)
          .autoFill('serendipity');

      expect(
        container.read(wordRegistrationProvider).translationFailed,
        isTrue,
      );
    });

    test('英例文が無ければ translationFailed は立たない', () async {
      container = buildContainer(
        wordInfoProvider: _FakeWordInfoProvider(
          (_) async => fetchedInfo.copyWith(exampleEn: '', exampleJa: ''),
        ),
      );

      await container
          .read(wordRegistrationProvider.notifier)
          .autoFill('serendipity');

      expect(
        container.read(wordRegistrationProvider).translationFailed,
        isFalse,
      );
    });

    test('自動入力後に保存すると audioUrl も書き込まれる', () async {
      container = buildContainer(
        wordInfoProvider: _FakeWordInfoProvider((_) async => fetchedInfo),
      );
      final notifier = container.read(wordRegistrationProvider.notifier);
      await notifier.autoFill('serendipity');

      await notifier.save(
        word: 'serendipity',
        ipa: fetchedInfo.ipa,
        japanese: fetchedInfo.japanese,
        exampleEn: fetchedInfo.exampleEn,
        exampleJa: fetchedInfo.exampleJa,
      );

      final words = await db.wordDao.watchAll().first;
      expect(words.single.audioUrl, 'https://example.com/a.mp3');
    });

    test('自動取得の品詞順は保たれ、手動で足した品詞は後ろに付く', () async {
      // 辞書は動詞を先に返す語(run など)を想定する。
      const verbFirst = WordInfo(
        word: 'run',
        ipa: '/ɹʌn/',
        partsOfSpeech: [PartOfSpeech.verb, PartOfSpeech.noun],
        japanese: '走る',
        exampleEn: '',
        exampleJa: '',
        audioUrl: '',
      );
      container = buildContainer(
        wordInfoProvider: _FakeWordInfoProvider((_) async => verbFirst),
      );
      final notifier = container.read(wordRegistrationProvider.notifier);
      await notifier.autoFill('run');

      // 動詞を外して付け直し、形容詞を足す。
      notifier
        ..togglePartOfSpeech(PartOfSpeech.verb)
        ..togglePartOfSpeech(PartOfSpeech.verb)
        ..togglePartOfSpeech(PartOfSpeech.adjective);

      await notifier.save(
        word: 'run',
        ipa: verbFirst.ipa,
        japanese: verbFirst.japanese,
        exampleEn: '',
        exampleJa: '',
      );

      final words = await db.wordDao.watchAll().first;
      // 辞書の主用法(動詞)が先頭のままで、バッジは動詞色になる。
      expect(words.single.partsOfSpeech, [
        PartOfSpeech.verb,
        PartOfSpeech.noun,
        PartOfSpeech.adjective,
      ]);
    });

    test('backToInput で取得結果と品詞選択が破棄される', () async {
      container = buildContainer(
        wordInfoProvider: _FakeWordInfoProvider((_) async => fetchedInfo),
      );
      final notifier = container.read(wordRegistrationProvider.notifier);
      await notifier.autoFill('serendipity');

      notifier.backToInput();

      final state = container.read(wordRegistrationProvider);
      expect(state.step, RegistrationStep.input);
      expect(state.fetched, isNull);
      expect(state.selectedPartsOfSpeech, isEmpty);
    });

    test('skipToManual は fetched なしで form へ遷移する', () async {
      container = buildContainer();

      container.read(wordRegistrationProvider.notifier).skipToManual();

      final state = container.read(wordRegistrationProvider);
      expect(state.step, RegistrationStep.form);
      expect(state.fetched, isNull);
      expect(state.notFound, isFalse);
    });
  });

  // 同じ単語が 2 件並ぶのは事故なので、登録させずに止める。
  group('重複登録', () {
    Future<void> insertApple() => db.wordDao.insertWord(
      const WordsCompanion(word: Value('apple'), japanese: Value('りんご')),
    );

    test('登録済みなら autoFill は辞書を引かず input に留まる', () async {
      await insertApple();
      var fetchCalled = false;
      container = buildContainer(
        wordInfoProvider: _FakeWordInfoProvider((_) async {
          fetchCalled = true;
          return null;
        }),
      );

      await container.read(wordRegistrationProvider.notifier).autoFill('apple');

      final state = container.read(wordRegistrationProvider);
      expect(fetchCalled, isFalse);
      expect(state.step, RegistrationStep.input);
      expect(state.errorMessage, '「apple」は既に登録されています。');
    });

    test('大文字違い・前後空白でも autoFill は弾く', () async {
      await insertApple();
      container = buildContainer(
        wordInfoProvider: _FakeWordInfoProvider((_) async => null),
      );

      await container
          .read(wordRegistrationProvider.notifier)
          .autoFill('  Apple ');

      expect(
        container.read(wordRegistrationProvider).errorMessage,
        '「apple」は既に登録されています。',
      );
    });

    test('save も弾き、単語は増えない(フォームで書き換えた場合の保険)', () async {
      await insertApple();
      container = buildContainer();

      final result = await container
          .read(wordRegistrationProvider.notifier)
          .save(
            word: 'Apple',
            ipa: '',
            japanese: 'りんご',
            exampleEn: '',
            exampleJa: '',
          );

      expect(result, isFalse);
      expect(
        container.read(wordRegistrationProvider).errorMessage,
        '「apple」は既に登録されています。',
      );
      expect(await db.wordDao.watchAll().first, hasLength(1));
    });
  });

  // 句動詞を登録できるようになったので、語の間に空白を重ねて入力されうる。
  // そのまま通すと kaikki のパスが 404 になり、重複判定もすり抜ける。
  group('句動詞の空白正規化', () {
    test('autoFill は語間の連続空白を 1 つに畳んで辞書を引く', () async {
      String? requested;
      container = buildContainer(
        wordInfoProvider: _FakeWordInfoProvider((word) async {
          requested = word;
          return null;
        }),
      );

      await container
          .read(wordRegistrationProvider.notifier)
          .autoFill('  give   up ');

      expect(requested, 'give up');
    });

    test('save も畳んだ形で保存する', () async {
      container = buildContainer();

      await container
          .read(wordRegistrationProvider.notifier)
          .save(
            word: 'give   up',
            ipa: '',
            japanese: 'あきらめる',
            exampleEn: '',
            exampleJa: '',
          );

      expect((await db.wordDao.getAll()).single.word, 'give up');
    });
  });
}
