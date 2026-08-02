// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'license_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ライセンス一覧。[LicenseRegistry.licenses] は Stream なので読み切ってから返す。

@ProviderFor(licenseList)
final licenseListProvider = LicenseListProvider._();

/// ライセンス一覧。[LicenseRegistry.licenses] は Stream なので読み切ってから返す。

final class LicenseListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LicenseItem>>,
          List<LicenseItem>,
          FutureOr<List<LicenseItem>>
        >
    with
        $FutureModifier<List<LicenseItem>>,
        $FutureProvider<List<LicenseItem>> {
  /// ライセンス一覧。[LicenseRegistry.licenses] は Stream なので読み切ってから返す。
  LicenseListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'licenseListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$licenseListHash();

  @$internal
  @override
  $FutureProviderElement<List<LicenseItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LicenseItem>> create(Ref ref) {
    return licenseList(ref);
  }
}

String _$licenseListHash() => r'99d019e9cde228e5be8c5a0c4b5a61240b38f6d4';
