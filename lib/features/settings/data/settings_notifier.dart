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

  final _prefs = SharedPreferencesAsync();

  @override
  Future<SettingsState> build() async {
    final directionName = await _prefs.getString(_keyQuizDirection);
    final showIpa = await _prefs.getBool(_keyShowIpa);
    return SettingsState(
      quizDirection:
          QuizDirection.values.asNameMap()[directionName] ??
          QuizDirection.enToJa,
      showIpa: showIpa ?? true,
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
}
