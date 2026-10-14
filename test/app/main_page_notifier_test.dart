import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/features/analytics/data/analytics_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/analytics/fake_analytics_client.dart';

void main() {
  // flutter_riverpod のスケジューラは binding のフレーム処理に乗るため、
  // ウィジェットを出さないテストでも binding を初期化しておく。
  TestWidgetsFlutterBinding.ensureInitialized();

  test('search_used は検索語が空から非空になったときだけ、画面を付けて送る', () {
    final analytics = FakeAnalyticsClient();
    final container = ProviderContainer(
      overrides: [analyticsClientProvider.overrideWithValue(analytics)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(mainPageProvider, (_, _) {});
    addTearDown(subscription.close);
    final notifier = container.read(mainPageProvider.notifier)
      ..selectView(MainView.allWords)
      // 打ち進めても、空白だけでも送らない。消して打ち直したら送る。
      ..updateSearchQuery(' ')
      ..updateSearchQuery('a')
      ..updateSearchQuery('ap')
      ..updateSearchQuery('');
    notifier.updateSearchQuery('b');

    expect(analytics.eventsNamed('search_used'), [
      {'screen': 'all_words'},
      {'screen': 'all_words'},
    ]);
  });
}
