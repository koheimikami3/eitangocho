import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/word_sort_order.dart';
import 'package:eitangocho/features/word/data/word_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

Word _word(
  int id,
  String word, {
  required DateTime createdAt,
  bool isLearned = false,
  int correctCount = 0,
}) => Word(
  id: id,
  word: word,
  meaning: '$word の訳',
  ipa: '',
  partsOfSpeech: const <PartOfSpeech>[],
  exampleEn: '',
  exampleTranslation: '',
  translationLanguage: 'ja',
  audioUrl: '',
  isLearned: isLearned,
  correctCount: correctCount,
  createdAt: createdAt,
  updatedAt: createdAt,
);

void main() {
  // flutter_riverpod のスケジューラは binding のフレーム処理に乗るため、
  // ウィジェットを出さないテストでも binding を初期化しておく。
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // 並び順の設定は SharedPreferencesAsync から読むため、インメモリ実装を差し込む。
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  // wordListProvider が流す並び(WordDao.watchAll と同じ登録日の新しい順)。
  // cherry と apple は同時刻に登録した想定で、id の大きい cherry が先。
  final words = [
    _word(4, 'banana', createdAt: DateTime(2026, 3), correctCount: 1),
    _word(
      3,
      'cherry',
      createdAt: DateTime(2026, 2),
      isLearned: true,
      correctCount: 3,
    ),
    _word(2, 'Apple', createdAt: DateTime(2026, 2), correctCount: 1),
    _word(1, 'date', createdAt: DateTime(2026), isLearned: true),
  ];

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        // drift の watch() を経由せず、固定の一覧から派生させて検証する。
        wordListProvider.overrideWith((ref) => Stream.value(words)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// 差し替えたストリームの初回発火と設定の読み込みを待つ。
  /// 購読者がいないと StreamProvider は値を流さないため、listen してから待つ。
  Future<void> warmUp(ProviderContainer container) async {
    container.listen(wordListProvider, (_, _) {});
    container.listen(settingsProvider, (_, _) {});
    await container.read(settingsProvider.future);
    await pumpEventQueue();
  }

  Future<List<String>> sortedBy(WordSortOrder order) async {
    final container = makeContainer();
    await warmUp(container);
    await container.read(settingsProvider.notifier).setWordSortOrder(order);
    return container.read(filteredWordListProvider).map((w) => w.word).toList();
  }

  test('既定は登録日の新しい順(同時刻は id の新しい順)', () async {
    final container = makeContainer();
    await warmUp(container);

    expect(container.read(filteredWordListProvider).map((w) => w.word), [
      'banana',
      'cherry',
      'Apple',
      'date',
    ]);
  });

  test('登録日が古い順は新しい順のちょうど逆になる', () async {
    expect(await sortedBy(WordSortOrder.oldest), [
      'date',
      'Apple',
      'cherry',
      'banana',
    ]);
  });

  test('アルファベット順は大文字小文字を区別しない', () async {
    expect(await sortedBy(WordSortOrder.alphabetical), [
      'Apple',
      'banana',
      'cherry',
      'date',
    ]);
    expect(await sortedBy(WordSortOrder.reverseAlphabetical), [
      'date',
      'cherry',
      'banana',
      'Apple',
    ]);
  });

  test('学習状態で並べ、同じ状態の中は登録日の新しい順', () async {
    expect(await sortedBy(WordSortOrder.learningFirst), [
      'banana',
      'Apple',
      'cherry',
      'date',
    ]);
    expect(await sortedBy(WordSortOrder.learnedFirst), [
      'cherry',
      'date',
      'banana',
      'Apple',
    ]);
  });

  test('覚えた回数で並べ、同じ回数の中は登録日の新しい順', () async {
    expect(await sortedBy(WordSortOrder.mostCorrect), [
      'cherry',
      'banana',
      'Apple',
      'date',
    ]);
    expect(await sortedBy(WordSortOrder.leastCorrect), [
      'date',
      'banana',
      'Apple',
      'cherry',
    ]);
  });

  test('検索で絞った結果も設定の並び順で返す', () async {
    final container = makeContainer();
    await warmUp(container);
    await container
        .read(settingsProvider.notifier)
        .setWordSortOrder(WordSortOrder.alphabetical);

    // 'a' は banana / Apple / date に一致する(英単語は大文字小文字を無視)。
    container.read(mainPageProvider.notifier).updateSearchQuery('a');
    expect(container.read(filteredWordListProvider).map((w) => w.word), [
      'Apple',
      'banana',
      'date',
    ]);
  });
}
