import 'package:eitangocho/db/app_database.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_page_state.freezed.dart';

/// クイズセッションの局面。
enum QuizPhase { empty, active, done }

@freezed
abstract class QuizPageState with _$QuizPageState {
  const factory QuizPageState({
    @Default(QuizPhase.empty) QuizPhase phase,

    /// セッション開始時に学習済み単語をシャッフルしたスナップショット。
    /// セッション中の learned 変更・編集・削除は進行に影響させない。
    @Default(<Word>[]) List<Word> questions,
    @Default(0) int index,
    @Default(false) bool revealed,
    @Default(0) int okCount,
    @Default(<Word>[]) List<Word> forgotWords,
  }) = _QuizPageState;
}
