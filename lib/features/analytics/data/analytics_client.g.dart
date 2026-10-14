// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 計測の実装。main.dart で Firebase の実装に差し替える。

@ProviderFor(analyticsClient)
final analyticsClientProvider = AnalyticsClientProvider._();

/// 計測の実装。main.dart で Firebase の実装に差し替える。

final class AnalyticsClientProvider
    extends
        $FunctionalProvider<AnalyticsClient, AnalyticsClient, AnalyticsClient>
    with $Provider<AnalyticsClient> {
  /// 計測の実装。main.dart で Firebase の実装に差し替える。
  AnalyticsClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsClientHash();

  @$internal
  @override
  $ProviderElement<AnalyticsClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnalyticsClient create(Ref ref) {
    return analyticsClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsClient>(value),
    );
  }
}

String _$analyticsClientHash() => r'e8233790d12aa76b61dcfde624e174d37a3f69df';
