import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_page_state.freezed.dart';

/// シェルで切り替えるビュー。既定は学習中(プロトタイプの初期表示)。
enum MainView {
  learning,
  allWords,
  quiz,
  registration,
  settings;

  /// ツールバーに検索フィールドを持つビューか。
  /// ⌘F(検索フォーカス)の有効/無効判定に使う。
  bool get hasSearchField =>
      this == MainView.learning || this == MainView.allWords;
}

@freezed
abstract class MainPageState with _$MainPageState {
  const factory MainPageState({
    @Default(MainView.learning) MainView view,
    @Default('') String searchQuery,
  }) = _MainPageState;
}
