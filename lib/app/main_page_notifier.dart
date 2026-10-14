import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/features/analytics/data/analytics_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main_page_notifier.g.dart';

@riverpod
class MainPageNotifier extends _$MainPageNotifier {
  @override
  MainPageState build() => const MainPageState();

  void selectView(MainView view) => state = state.copyWith(view: view);
  void updateSearchQuery(String query) {
    // 検索を使い始めた(空 → 非空)ときに 1 回だけ送る。打つたびには送らない。
    // 送るのは画面だけで、検索語そのものは送らない。
    if (state.searchQuery.trim().isEmpty && query.trim().isNotEmpty) {
      ref.read(analyticsLoggerProvider).logSearchUsed(state.view);
    }
    state = state.copyWith(searchQuery: query);
  }
}
