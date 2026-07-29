import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/word/data/learning_words_provider.dart';
import 'package:eitangocho/features/word/data/word_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Word _word(String word, String japanese, {bool isLearned = false}) => Word(
  id: word.hashCode,
  word: word,
  japanese: japanese,
  ipa: '',
  partsOfSpeech: const <PartOfSpeech>[],
  exampleEn: '',
  exampleJa: '',
  audioUrl: '',
  isLearned: isLearned,
  correctCount: 0,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  // flutter_riverpod のスケジューラは binding のフレーム処理に乗るため、
  // ウィジェットを出さないテストでも binding を初期化しておく。
  TestWidgetsFlutterBinding.ensureInitialized();

  final words = [
    _word('apple', 'りんご'),
    _word('Banana', 'バナナ'),
    _word('orange', 'オレンジ', isLearned: true),
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

  /// 差し替えたストリームの初回発火を待つ。
  /// 購読者がいないと StreamProvider は値を流さないため、listen してから待つ。
  Future<void> warmUp(ProviderContainer container) async {
    container.listen(wordListProvider, (_, _) {});
    await pumpEventQueue();
  }

  test('学習済みを除いた一覧を返す', () async {
    final container = makeContainer();
    await warmUp(container);

    expect(
      container.read(filteredLearningWordsProvider).map((w) => w.word),
      ['apple', 'Banana'],
    );
  });

  test('検索は英単語が大文字小文字を無視した部分一致、日本語訳は部分一致', () async {
    final container = makeContainer();
    await warmUp(container);

    container.read(mainPageProvider.notifier).updateSearchQuery('ban');
    expect(
      container.read(filteredLearningWordsProvider).map((w) => w.word),
      ['Banana'],
    );

    container.read(mainPageProvider.notifier).updateSearchQuery('りんご');
    expect(
      container.read(filteredLearningWordsProvider).map((w) => w.word),
      ['apple'],
    );
  });

  test('検索語が学習済みの単語に一致しても出さない', () async {
    final container = makeContainer();
    await warmUp(container);

    container.read(mainPageProvider.notifier).updateSearchQuery('orange');

    expect(container.read(filteredLearningWordsProvider), isEmpty);
  });
}
