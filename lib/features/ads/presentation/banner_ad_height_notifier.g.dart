// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_ad_height_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// バナー広告が実際に占めている高さ。コンテンツの下余白に足すために公開する。
///
/// アンカー型アダプティブバナーの高さは端末ごとに Google が返す値で決まり、
/// 読み込みが終わるまで分からない。読み込み前・失敗時・シートに覆われて
/// いる間は 0 で、そのときはタブバーの高さだけを空ければよい。
///
/// keepAlive にするのは、書き手(バナー)と読み手(シェル)が別ウィジェット
/// のため。購読者が一瞬でも居ない状態で書くと autoDispose が値ごと捨て、
/// 次に読んだときは初期値に戻ってしまう。

@ProviderFor(BannerAdHeight)
final bannerAdHeightProvider = BannerAdHeightProvider._();

/// バナー広告が実際に占めている高さ。コンテンツの下余白に足すために公開する。
///
/// アンカー型アダプティブバナーの高さは端末ごとに Google が返す値で決まり、
/// 読み込みが終わるまで分からない。読み込み前・失敗時・シートに覆われて
/// いる間は 0 で、そのときはタブバーの高さだけを空ければよい。
///
/// keepAlive にするのは、書き手(バナー)と読み手(シェル)が別ウィジェット
/// のため。購読者が一瞬でも居ない状態で書くと autoDispose が値ごと捨て、
/// 次に読んだときは初期値に戻ってしまう。
final class BannerAdHeightProvider
    extends $NotifierProvider<BannerAdHeight, double> {
  /// バナー広告が実際に占めている高さ。コンテンツの下余白に足すために公開する。
  ///
  /// アンカー型アダプティブバナーの高さは端末ごとに Google が返す値で決まり、
  /// 読み込みが終わるまで分からない。読み込み前・失敗時・シートに覆われて
  /// いる間は 0 で、そのときはタブバーの高さだけを空ければよい。
  ///
  /// keepAlive にするのは、書き手(バナー)と読み手(シェル)が別ウィジェット
  /// のため。購読者が一瞬でも居ない状態で書くと autoDispose が値ごと捨て、
  /// 次に読んだときは初期値に戻ってしまう。
  BannerAdHeightProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bannerAdHeightProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bannerAdHeightHash();

  @$internal
  @override
  BannerAdHeight create() => BannerAdHeight();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$bannerAdHeightHash() => r'641885f656cf1885219e2438ac26f3971d44281c';

/// バナー広告が実際に占めている高さ。コンテンツの下余白に足すために公開する。
///
/// アンカー型アダプティブバナーの高さは端末ごとに Google が返す値で決まり、
/// 読み込みが終わるまで分からない。読み込み前・失敗時・シートに覆われて
/// いる間は 0 で、そのときはタブバーの高さだけを空ければよい。
///
/// keepAlive にするのは、書き手(バナー)と読み手(シェル)が別ウィジェット
/// のため。購読者が一瞬でも居ない状態で書くと autoDispose が値ごと捨て、
/// 次に読んだときは初期値に戻ってしまう。

abstract class _$BannerAdHeight extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
