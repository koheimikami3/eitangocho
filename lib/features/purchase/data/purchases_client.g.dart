// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchases_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 課金の実装。テストではフェイクに差し替える。

@ProviderFor(purchasesClient)
final purchasesClientProvider = PurchasesClientProvider._();

/// 課金の実装。テストではフェイクに差し替える。

final class PurchasesClientProvider
    extends
        $FunctionalProvider<PurchasesClient, PurchasesClient, PurchasesClient>
    with $Provider<PurchasesClient> {
  /// 課金の実装。テストではフェイクに差し替える。
  PurchasesClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchasesClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchasesClientHash();

  @$internal
  @override
  $ProviderElement<PurchasesClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PurchasesClient create(Ref ref) {
    return purchasesClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchasesClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchasesClient>(value),
    );
  }
}

String _$purchasesClientHash() => r'95bf5938650aa93fbcd52eb99e478328d3f9d056';
