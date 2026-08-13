// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// レビュー依頼の実装。テストではフェイクに差し替える。

@ProviderFor(reviewClient)
final reviewClientProvider = ReviewClientProvider._();

/// レビュー依頼の実装。テストではフェイクに差し替える。

final class ReviewClientProvider
    extends $FunctionalProvider<ReviewClient, ReviewClient, ReviewClient>
    with $Provider<ReviewClient> {
  /// レビュー依頼の実装。テストではフェイクに差し替える。
  ReviewClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewClientHash();

  @$internal
  @override
  $ProviderElement<ReviewClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReviewClient create(Ref ref) {
    return reviewClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewClient>(value),
    );
  }
}

String _$reviewClientHash() => r'fc416018309d7a24182199bb5133cb92c43a42c2';
