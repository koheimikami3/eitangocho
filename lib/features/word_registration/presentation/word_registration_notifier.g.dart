// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_registration_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WordRegistrationNotifier)
final wordRegistrationProvider = WordRegistrationNotifierProvider._();

final class WordRegistrationNotifierProvider
    extends $NotifierProvider<WordRegistrationNotifier, WordRegistrationState> {
  WordRegistrationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordRegistrationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordRegistrationNotifierHash();

  @$internal
  @override
  WordRegistrationNotifier create() => WordRegistrationNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WordRegistrationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WordRegistrationState>(value),
    );
  }
}

String _$wordRegistrationNotifierHash() =>
    r'2cdaf6b8d128b275fba3ca854001711924cd7d12';

abstract class _$WordRegistrationNotifier
    extends $Notifier<WordRegistrationState> {
  WordRegistrationState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WordRegistrationState, WordRegistrationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WordRegistrationState, WordRegistrationState>,
              WordRegistrationState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
