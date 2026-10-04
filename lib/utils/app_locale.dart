import 'dart:ui';

import 'package:eitangocho/features/settings/domain/translation_language.dart';

/// 画面の表示言語の解決を 1 箇所に集約する。
///
/// 対応は日本語・英語・繁体字中国語。端末の優先言語を上から見て、最初に
/// 対応しているものを採る。どれも無ければ英語にする(対応外の言語の端末向け)。
abstract final class AppLocale {
  static const ja = Locale('ja');
  static const en = Locale('en');
  static const zhHant = Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hant',
  );

  /// MaterialApp に渡す対応言語。生成された AppLocalizations.supportedLocales
  /// には gen-l10n の都合で置いた素の `zh` も入るので、こちらを使う。
  static const supported = [ja, en, zhHant];

  /// 繁体字とみなす地域。iOS は `zh-Hant-TW` のように文字体系を付けて渡すが、
  /// 文字体系の無い `zh-TW` 形式でも判定できるようにする。
  static const _traditionalRegions = {'TW', 'HK', 'MO'};

  /// [preferred](端末の優先言語の並び)から表示言語を決める。
  ///
  /// **簡体字は対応言語として扱わず、次の候補へ進む**。繁体字の画面を
  /// 簡体字の利用者に出すより、英語の方が読みやすいため。
  static Locale resolve(List<Locale>? preferred) {
    for (final locale in preferred ?? const <Locale>[]) {
      switch (locale.languageCode) {
        case 'ja':
          return ja;
        case 'en':
          return en;
        case 'zh' when _isTraditional(locale):
          return zhHant;
      }
    }
    return en;
  }

  static bool _isTraditional(Locale locale) =>
      locale.scriptCode == 'Hant' ||
      (locale.scriptCode == null &&
          _traditionalRegions.contains(locale.countryCode));

  /// 訳の言語の既定。繁体字の画面なら繁体字、それ以外は日本語。
  ///
  /// 英語の画面になる利用者も日本語にするのは、今の利用者のほとんどが
  /// 日本語話者で(端末を英語にしている海外在住者を含む)、英語を英語で
  /// 訳すことはできないため。
  static TranslationLanguage defaultTranslationLanguage(Locale appLocale) =>
      appLocale.languageCode == 'zh'
      ? TranslationLanguage.zhHant
      : TranslationLanguage.ja;

  /// この端末での訳の言語の既定(設定が未保存のときに使う)。
  static TranslationLanguage get deviceDefaultTranslationLanguage =>
      defaultTranslationLanguage(resolve(PlatformDispatcher.instance.locales));
}
