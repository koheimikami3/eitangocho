// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// アプリ設定を shared_preferences に読み書きするラッパー。
/// build で非同期に読み込むため、購読側は `AsyncValue<SettingsState>` を扱う
/// (ロード前は既定値でフォールバックしてよい)。変更は即保存する。

@ProviderFor(SettingsNotifier)
final settingsProvider = SettingsNotifierProvider._();

/// アプリ設定を shared_preferences に読み書きするラッパー。
/// build で非同期に読み込むため、購読側は `AsyncValue<SettingsState>` を扱う
/// (ロード前は既定値でフォールバックしてよい)。変更は即保存する。
final class SettingsNotifierProvider
    extends $AsyncNotifierProvider<SettingsNotifier, SettingsState> {
  /// アプリ設定を shared_preferences に読み書きするラッパー。
  /// build で非同期に読み込むため、購読側は `AsyncValue<SettingsState>` を扱う
  /// (ロード前は既定値でフォールバックしてよい)。変更は即保存する。
  SettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsNotifierHash();

  @$internal
  @override
  SettingsNotifier create() => SettingsNotifier();
}

String _$settingsNotifierHash() => r'07d825e262e8467bfc1f1a3bc0a7519535bb5a90';

/// アプリ設定を shared_preferences に読み書きするラッパー。
/// build で非同期に読み込むため、購読側は `AsyncValue<SettingsState>` を扱う
/// (ロード前は既定値でフォールバックしてよい)。変更は即保存する。

abstract class _$SettingsNotifier extends $AsyncNotifier<SettingsState> {
  FutureOr<SettingsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SettingsState>, SettingsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SettingsState>, SettingsState>,
              AsyncValue<SettingsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
