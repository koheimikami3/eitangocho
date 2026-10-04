import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/features/settings/domain/app_appearance.dart';
import 'package:eitangocho/features/settings/domain/learning_card_layout.dart';
import 'package:eitangocho/features/settings/domain/quiz_direction.dart';
import 'package:eitangocho/features/settings/domain/translation_language.dart';
import 'package:eitangocho/features/settings/domain/word_sort_order.dart';
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

    /// UI 全体の拡大率(EitangochoApp がブラウザズーム相当で適用する)。
    /// macOS 専用。iOS では OS の文字サイズ設定に委ねるため無視される。
    @Default(AppDimensions.defaultUiScale) double uiScale,

    /// 配色(ライト / ダーク)。iOS 専用で、macOS は常にライト。
    @Default(AppAppearance.light) AppAppearance appearance,

    /// 学習中カードの並び(1 列 / 2 列)。iOS 専用。
    @Default(LearningCardLayout.twoColumns) LearningCardLayout cardLayout,

    /// 全単語一覧の並び順。
    @Default(WordSortOrder.newest) WordSortOrder wordSortOrder,

    /// 訳の言語。未保存のときは端末の言語から決める(SettingsNotifier.build)。
    @Default(TranslationLanguage.ja) TranslationLanguage translationLanguage,
  }) = _SettingsState;
}
