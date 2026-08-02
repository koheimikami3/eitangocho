// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 表示用のアプリバージョン(`1.1.0` 形式)。
///
/// pubspec の値を macOS / iOS の両方が読むため、ここもネイティブのバンドルから
/// 取る(定数で持つと pubspec と二重管理になり、上げ忘れる)。

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// 表示用のアプリバージョン(`1.1.0` 形式)。
///
/// pubspec の値を macOS / iOS の両方が読むため、ここもネイティブのバンドルから
/// 取る(定数で持つと pubspec と二重管理になり、上げ忘れる)。

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// 表示用のアプリバージョン(`1.1.0` 形式)。
  ///
  /// pubspec の値を macOS / iOS の両方が読むため、ここもネイティブのバンドルから
  /// 取る(定数で持つと pubspec と二重管理になり、上げ忘れる)。
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'ba3c22ffcbb681a34abb9097ad16cde90c9e2247';
