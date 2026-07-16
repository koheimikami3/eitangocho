import 'package:eitangocho/features/settings/domain/quiz_direction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

/// アプリ設定。shared_preferences に永続化する(SettingsNotifier 参照)。
@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(QuizDirection.enToJa) QuizDirection quizDirection,
    @Default(true) bool showIpa,
  }) = _SettingsState;
}
