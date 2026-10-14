import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/analytics/data/analytics_client.dart';
import 'package:eitangocho/features/analytics/data/analytics_reporter.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/settings/domain/word_sort_order.dart';
import 'package:eitangocho/features/word/data/word_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../fake_analytics_client.dart';

Word _word(int id) => Word(
  id: id,
  word: 'word$id',
  ipa: '',
  meaning: '訳$id',
  partsOfSpeech: const <PartOfSpeech>[],
  exampleEn: '',
  exampleTranslation: '',
  translationLanguage: 'ja',
  audioUrl: '',
  isLearned: false,
  correctCount: 0,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  // flutter_riverpod のスケジューラは binding のフレーム処理に乗るため、
  // ウィジェットを出さないテストでも binding を初期化しておく。
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAnalyticsClient client;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    client = FakeAnalyticsClient();
  });

  /// 単語一覧は drift の watch() ではなく、テストから流せるストリームにする
  /// (container 破棄時の購読解除タイマーとの衝突を避けるため)。
  Future<ProviderContainer> start(Stream<List<Word>> words) async {
    final container = ProviderContainer(
      overrides: [
        analyticsClientProvider.overrideWithValue(client),
        wordListProvider.overrideWith((ref) => words),
      ],
    );
    addTearDown(container.dispose);
    container.listen(analyticsReporterProvider, (_, _) {});
    await container.read(settingsProvider.future);
    await pumpEventQueue();
    return container;
  }

  test('設定と単語数をユーザープロパティにする', () async {
    await start(Stream.value([_word(1), _word(2)]));

    expect(client.userProperties, containsPair('word_count_bucket', '1_1-9'));
    expect(client.userProperties, containsPair('show_ipa', 'true'));
    expect(
      client.userProperties,
      containsPair('quiz_direction', 'from_english'),
    );
    expect(client.userProperties, containsPair('word_sort_order', 'newest'));
    expect(client.userProperties, containsPair('sync_enabled', 'false'));
  });

  test('値が変わったときだけ送り直す', () async {
    final container = await start(Stream.value(const []));
    final before = client.userPropertyCalls;

    // 並び順だけを変えると、送り直すのも並び順だけ。
    await container
        .read(settingsProvider.notifier)
        .setWordSortOrder(WordSortOrder.alphabetical);
    await pumpEventQueue();

    expect(client.userPropertyCalls, before + 1);
    expect(client.userProperties['word_sort_order'], 'alphabetical');
  });

  test('主画面を切り替えるたびに screen_view を送る', () async {
    final container = await start(Stream.value(const []));

    container.read(mainPageProvider.notifier).selectView(MainView.allWords);
    await pumpEventQueue();

    expect(client.eventsNamed('screen_view'), [
      {'screen_name': 'learning'},
      {'screen_name': 'all_words'},
    ]);
  });
}
