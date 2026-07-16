// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_word_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 登録 Notifier はこの Provider 経由でのみ WordInfoProvider を取得する
/// (具象クラスを直接 new しない。将来の LLM 実装への差し替えポイント)。
// 関数名を wordInfo にすると生成クラス名がドメインの WordInfoProvider 抽象と
// 衝突するため、あえて wordInfoProvider(生成 Provider は wordInfoProviderProvider)とする。

@ProviderFor(wordInfoProvider)
final wordInfoProviderProvider = WordInfoProviderProvider._();

/// 登録 Notifier はこの Provider 経由でのみ WordInfoProvider を取得する
/// (具象クラスを直接 new しない。将来の LLM 実装への差し替えポイント)。
// 関数名を wordInfo にすると生成クラス名がドメインの WordInfoProvider 抽象と
// 衝突するため、あえて wordInfoProvider(生成 Provider は wordInfoProviderProvider)とする。

final class WordInfoProviderProvider
    extends
        $FunctionalProvider<
          WordInfoProvider,
          WordInfoProvider,
          WordInfoProvider
        >
    with $Provider<WordInfoProvider> {
  /// 登録 Notifier はこの Provider 経由でのみ WordInfoProvider を取得する
  /// (具象クラスを直接 new しない。将来の LLM 実装への差し替えポイント)。
  // 関数名を wordInfo にすると生成クラス名がドメインの WordInfoProvider 抽象と
  // 衝突するため、あえて wordInfoProvider(生成 Provider は wordInfoProviderProvider)とする。
  WordInfoProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordInfoProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordInfoProviderHash();

  @$internal
  @override
  $ProviderElement<WordInfoProvider> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WordInfoProvider create(Ref ref) {
    return wordInfoProvider(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WordInfoProvider value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WordInfoProvider>(value),
    );
  }
}

String _$wordInfoProviderHash() => r'44f5c719e846c5705f585950d3f075079354ad1b';
