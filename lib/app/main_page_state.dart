import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_page_state.freezed.dart';

/// シェルで切り替えるビュー。Phase 2 で learning / quiz / settings を追加する。
enum MainView { allWords, registration }

@freezed
abstract class MainPageState with _$MainPageState {
  const factory MainPageState({
    @Default(MainView.allWords) MainView view,
    @Default('') String searchQuery,
  }) = _MainPageState;
}
