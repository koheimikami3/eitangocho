import 'package:eitangocho/features/settings/domain/quiz_direction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

/// アプリ設定。shared_preferences に永続化する(SettingsNotifier 参照)。
@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(QuizDirection.enToJa) QuizDirection quizDirection,
    @Default(true) bool showIpa,

    /// DeepL API Free のキー。未設定(空)なら例文の和訳をスキップする。
    /// ローカル個人アプリとして平文保存を許容する(確定済みの設計判断)。
    @Default('') String deeplApiKey,
  }) = _SettingsState;
}
