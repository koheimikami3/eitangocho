// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ads_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 広告を表示してよいか。true を返した時点で広告 SDK は初期化済み。
///
/// 広告の出し分けはこの真偽値 1 点に集約する。将来「広告非表示」の課金を
/// 足すときも、購入状態をここに混ぜるだけで表示側は変えずに済む。
///
/// keepAlive にするのは、バナーがツリーから外れる(シート表示中など)たびに
/// SDK の初期化と ATT の確認をやり直さないため。

@ProviderFor(adsEnabled)
final adsEnabledProvider = AdsEnabledProvider._();

/// 広告を表示してよいか。true を返した時点で広告 SDK は初期化済み。
///
/// 広告の出し分けはこの真偽値 1 点に集約する。将来「広告非表示」の課金を
/// 足すときも、購入状態をここに混ぜるだけで表示側は変えずに済む。
///
/// keepAlive にするのは、バナーがツリーから外れる(シート表示中など)たびに
/// SDK の初期化と ATT の確認をやり直さないため。

final class AdsEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// 広告を表示してよいか。true を返した時点で広告 SDK は初期化済み。
  ///
  /// 広告の出し分けはこの真偽値 1 点に集約する。将来「広告非表示」の課金を
  /// 足すときも、購入状態をここに混ぜるだけで表示側は変えずに済む。
  ///
  /// keepAlive にするのは、バナーがツリーから外れる(シート表示中など)たびに
  /// SDK の初期化と ATT の確認をやり直さないため。
  AdsEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adsEnabledProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adsEnabledHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return adsEnabled(ref);
  }
}

String _$adsEnabledHash() => r'7cafec4cc4c790649983f12e238c39da1e059425';
