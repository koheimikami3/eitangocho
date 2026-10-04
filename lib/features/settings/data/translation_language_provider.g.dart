// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_language_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 今の訳の言語。項目名(「日本語訳」など)や取得元の切り替えはここから引く。
///
/// 設定のロード前も端末の言語から決めた既定を返す。SettingsState の既定値
/// (ja)にフォールバックすると、繁体字の利用者に一瞬「日本語訳」が出るため。

@ProviderFor(translationLanguage)
final translationLanguageProvider = TranslationLanguageProvider._();

/// 今の訳の言語。項目名(「日本語訳」など)や取得元の切り替えはここから引く。
///
/// 設定のロード前も端末の言語から決めた既定を返す。SettingsState の既定値
/// (ja)にフォールバックすると、繁体字の利用者に一瞬「日本語訳」が出るため。

final class TranslationLanguageProvider
    extends
        $FunctionalProvider<
          TranslationLanguage,
          TranslationLanguage,
          TranslationLanguage
        >
    with $Provider<TranslationLanguage> {
  /// 今の訳の言語。項目名(「日本語訳」など)や取得元の切り替えはここから引く。
  ///
  /// 設定のロード前も端末の言語から決めた既定を返す。SettingsState の既定値
  /// (ja)にフォールバックすると、繁体字の利用者に一瞬「日本語訳」が出るため。
  TranslationLanguageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'translationLanguageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$translationLanguageHash();

  @$internal
  @override
  $ProviderElement<TranslationLanguage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TranslationLanguage create(Ref ref) {
    return translationLanguage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TranslationLanguage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TranslationLanguage>(value),
    );
  }
}

String _$translationLanguageHash() =>
    r'09998b3a947e0c2af1dd27e39688631e8df88e70';
