// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ATT の実装。テストではフェイクに差し替える。

@ProviderFor(trackingClient)
final trackingClientProvider = TrackingClientProvider._();

/// ATT の実装。テストではフェイクに差し替える。

final class TrackingClientProvider
    extends $FunctionalProvider<TrackingClient, TrackingClient, TrackingClient>
    with $Provider<TrackingClient> {
  /// ATT の実装。テストではフェイクに差し替える。
  TrackingClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackingClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackingClientHash();

  @$internal
  @override
  $ProviderElement<TrackingClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TrackingClient create(Ref ref) {
    return trackingClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrackingClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrackingClient>(value),
    );
  }
}

String _$trackingClientHash() => r'0189c922b626b3437ac5fe573f36e4d1aba63af7';
