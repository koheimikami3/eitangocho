import 'package:eitangocho/app/main_page_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main_page_notifier.g.dart';

@riverpod
class MainPageNotifier extends _$MainPageNotifier {
  @override
  MainPageState build() => const MainPageState();

  void selectView(MainView view) => state = state.copyWith(view: view);
  void updateSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);
}
