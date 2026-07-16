// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_page_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MainPageNotifier)
final mainPageProvider = MainPageNotifierProvider._();

final class MainPageNotifierProvider
    extends $NotifierProvider<MainPageNotifier, MainPageState> {
  MainPageNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mainPageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mainPageNotifierHash();

  @$internal
  @override
  MainPageNotifier create() => MainPageNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MainPageState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MainPageState>(value),
    );
  }
}

String _$mainPageNotifierHash() => r'5ef35f1ecdf5a9d0b54202d58f7a0e5e4eb76ad3';

abstract class _$MainPageNotifier extends $Notifier<MainPageState> {
  MainPageState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MainPageState, MainPageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MainPageState, MainPageState>,
              MainPageState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
