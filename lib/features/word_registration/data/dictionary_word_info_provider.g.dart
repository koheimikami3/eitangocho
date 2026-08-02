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
//
// keepAlive にするのは http.Client のライフサイクルを守るため。autoDispose だと、
// Notifier が ref.read()(購読を保持しない)で取得した直後に破棄予約され、
// fetch() の最初の await で制御を手放した隙に onDispose の httpClient.close() が走り、
// 続く API 呼び出しが "Client is already closed" で失敗する。依存する databaseProvider も
// keepAlive であり、http.Client はアプリ生存期間で 1 つ共有する(接続再利用の推奨形)。

@ProviderFor(wordInfoProvider)
final wordInfoProviderProvider = WordInfoProviderProvider._();

/// 登録 Notifier はこの Provider 経由でのみ WordInfoProvider を取得する
/// (具象クラスを直接 new しない。将来の LLM 実装への差し替えポイント)。
// 関数名を wordInfo にすると生成クラス名がドメインの WordInfoProvider 抽象と
// 衝突するため、あえて wordInfoProvider(生成 Provider は wordInfoProviderProvider)とする。
//
// keepAlive にするのは http.Client のライフサイクルを守るため。autoDispose だと、
// Notifier が ref.read()(購読を保持しない)で取得した直後に破棄予約され、
// fetch() の最初の await で制御を手放した隙に onDispose の httpClient.close() が走り、
// 続く API 呼び出しが "Client is already closed" で失敗する。依存する databaseProvider も
// keepAlive であり、http.Client はアプリ生存期間で 1 つ共有する(接続再利用の推奨形)。

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
  //
  // keepAlive にするのは http.Client のライフサイクルを守るため。autoDispose だと、
  // Notifier が ref.read()(購読を保持しない)で取得した直後に破棄予約され、
  // fetch() の最初の await で制御を手放した隙に onDispose の httpClient.close() が走り、
  // 続く API 呼び出しが "Client is already closed" で失敗する。依存する databaseProvider も
  // keepAlive であり、http.Client はアプリ生存期間で 1 つ共有する(接続再利用の推奨形)。
  WordInfoProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordInfoProviderProvider',
        isAutoDispose: false,
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

String _$wordInfoProviderHash() => r'aefb29f6edfe6b1b853386ff8a9683a9d79f06b8';
