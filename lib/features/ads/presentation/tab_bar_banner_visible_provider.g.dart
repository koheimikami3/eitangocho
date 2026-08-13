// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_bar_banner_visible_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// タブバー上のバナーを出してよい画面か。
///
/// 隠すのはクイズ結果だけ。あそこには 300x250 のレクタングルが出るため、
/// 両方並べると画面の 4 割が広告になり、忘れていた単語の一覧がほとんど
/// 読めなくなる。大きい方(レクタングル)を優先する。
///
/// レクタングルのユニットが未設定なら隠さない。広告がゼロの画面を作っても
/// 意味がないため。
/// 依存する 2 つの State は select せず丸ごと watch する(Provider 同士では
/// select が使えない)。この Provider 自身の値が変わったときだけ購読側は
/// 再構築されるため、実害は無い。

@ProviderFor(tabBarBannerVisible)
final tabBarBannerVisibleProvider = TabBarBannerVisibleProvider._();

/// タブバー上のバナーを出してよい画面か。
///
/// 隠すのはクイズ結果だけ。あそこには 300x250 のレクタングルが出るため、
/// 両方並べると画面の 4 割が広告になり、忘れていた単語の一覧がほとんど
/// 読めなくなる。大きい方(レクタングル)を優先する。
///
/// レクタングルのユニットが未設定なら隠さない。広告がゼロの画面を作っても
/// 意味がないため。
/// 依存する 2 つの State は select せず丸ごと watch する(Provider 同士では
/// select が使えない)。この Provider 自身の値が変わったときだけ購読側は
/// 再構築されるため、実害は無い。

final class TabBarBannerVisibleProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// タブバー上のバナーを出してよい画面か。
  ///
  /// 隠すのはクイズ結果だけ。あそこには 300x250 のレクタングルが出るため、
  /// 両方並べると画面の 4 割が広告になり、忘れていた単語の一覧がほとんど
  /// 読めなくなる。大きい方(レクタングル)を優先する。
  ///
  /// レクタングルのユニットが未設定なら隠さない。広告がゼロの画面を作っても
  /// 意味がないため。
  /// 依存する 2 つの State は select せず丸ごと watch する(Provider 同士では
  /// select が使えない)。この Provider 自身の値が変わったときだけ購読側は
  /// 再構築されるため、実害は無い。
  TabBarBannerVisibleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabBarBannerVisibleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabBarBannerVisibleHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return tabBarBannerVisible(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$tabBarBannerVisibleHash() =>
    r'6d0884688be47c1e395210fec5b5dbdc92fbc191';
