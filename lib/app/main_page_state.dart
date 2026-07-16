import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_page_state.freezed.dart';

/// シェルで切り替えるビュー。既定は学習中(プロトタイプの初期表示)。
enum MainView { learning, allWords, quiz, registration, settings }

@freezed
abstract class MainPageState with _$MainPageState {
  const factory MainPageState({
    @Default(MainView.learning) MainView view,
    @Default('') String searchQuery,
  }) = _MainPageState;
}
