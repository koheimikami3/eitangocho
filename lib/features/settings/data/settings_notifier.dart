import 'package:eitangocho/constants/app_dimensions.dart';
import 'package:eitangocho/features/settings/domain/app_appearance.dart';
import 'package:eitangocho/features/settings/domain/learning_card_layout.dart';
import 'package:eitangocho/features/settings/domain/quiz_direction.dart';
import 'package:eitangocho/features/settings/domain/settings_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_notifier.g.dart';

/// アプリ設定を shared_preferences に読み書きするラッパー。
/// build で非同期に読み込むため、購読側は `AsyncValue<SettingsState>` を扱う
/// (ロード前は既定値でフォールバックしてよい)。変更は即保存する。
@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  static const _keyQuizDirection = 'quizDirection';
  static const _keyShowIpa = 'showIpa';
  static const _keyDeeplApiKey = 'deeplApiKey';
  static const _keyUiScale = 'uiScale';
  static const _keyAppearance = 'appearance';
  static const _keyCardLayout = 'cardLayout';

  final _prefs = SharedPreferencesAsync();

  @override
  Future<SettingsState> build() async {
    final directionName = await _prefs.getString(_keyQuizDirection);
    final showIpa = await _prefs.getBool(_keyShowIpa);
    final deeplApiKey = await _prefs.getString(_keyDeeplApiKey);
    final uiScale = await _prefs.getDouble(_keyUiScale);
    final appearanceName = await _prefs.getString(_keyAppearance);
    final cardLayoutName = await _prefs.getString(_keyCardLayout);
    return SettingsState(
      quizDirection:
          QuizDirection.values.asNameMap()[directionName] ??
          QuizDirection.enToJa,
      showIpa: showIpa ?? true,
      deeplApiKey: deeplApiKey ?? '',
      uiScale: uiScale ?? AppDimensions.defaultUiScale,
      appearance:
          AppAppearance.values.asNameMap()[appearanceName] ??
          AppAppearance.light,
      cardLayout:
          LearningCardLayout.values.asNameMap()[cardLayoutName] ??
          LearningCardLayout.twoColumns,
    );
  }

  Future<void> setQuizDirection(QuizDirection direction) async {
    await _prefs.setString(_keyQuizDirection, direction.name);
    state = AsyncData(
      (state.value ?? const SettingsState()).copyWith(
        quizDirection: direction,
      ),
    );
  }

  Future<void> setShowIpa(bool value) async {
    await _prefs.setBool(_keyShowIpa, value);
    state = AsyncData(
      (state.value ?? const SettingsState()).copyWith(showIpa: value),
    );
  }

  Future<void> setDeeplApiKey(String value) async {
    await _prefs.setString(_keyDeeplApiKey, value.trim());
    state = AsyncData(
      (state.value ?? const SettingsState()).copyWith(
        deeplApiKey: value.trim(),
      ),
    );
  }

  Future<void> setAppearance(AppAppearance appearance) async {
    await _prefs.setString(_keyAppearance, appearance.name);
    state = AsyncData(
      (state.value ?? const SettingsState()).copyWith(appearance: appearance),
    );
  }

  Future<void> setCardLayout(LearningCardLayout layout) async {
    await _prefs.setString(_keyCardLayout, layout.name);
    state = AsyncData(
      (state.value ?? const SettingsState()).copyWith(cardLayout: layout),
    );
  }

  Future<void> setUiScale(double value) async {
    final clamped = value.clamp(
      AppDimensions.minUiScale,
      AppDimensions.maxUiScale,
    );
    await _prefs.setDouble(_keyUiScale, clamped);
    state = AsyncData(
      (state.value ?? const SettingsState()).copyWith(uiScale: clamped),
    );
  }
}
