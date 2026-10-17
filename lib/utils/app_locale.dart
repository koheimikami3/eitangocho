import 'dart:ui';

import 'package:eitangocho/features/settings/domain/translation_language.dart';

/// 画面の表示言語の解決を 1 箇所に集約する。
///
/// 対応は日本語・英語・繁体字中国語・スペイン語・フランス語。端末の優先言語を
/// 上から見て、最初に対応しているものを採る。どれも無ければ英語にする
/// (対応外の言語の端末向け)。スペイン語・フランス語は地域を区別しない。
abstract final class AppLocale {
  static const ja = Locale('ja');
  static const en = Locale('en');
  static const zhHant = Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hant',
  );
  static const es = Locale('es');
  static const fr = Locale('fr');

  /// MaterialApp に渡す対応言語。生成された AppLocalizations.supportedLocales
  /// には gen-l10n の都合で置いた素の `zh` も入るので、こちらを使う。
  static const supported = [ja, en, zhHant, es, fr];

  /// 繁体字とみなす地域。iOS は `zh-Hant-TW` のように文字体系を付けて渡すが、
  /// 文字体系の無い `zh-TW` 形式でも判定できるようにする。
  static const _traditionalRegions = {'TW', 'HK', 'MO'};

  /// [preferred](端末の優先言語の並び)から表示言語を決める。
  ///
  /// **簡体字は対応言語として扱わず、次の候補へ進む**。繁体字の画面を
  /// 簡体字の利用者に出すより、英語の方が読みやすいため。
  static Locale resolve(List<Locale>? preferred) => _match(preferred) ?? en;

  /// [preferred] に対応言語が 1 つも無いか(ドイツ語・韓国語・簡体字の端末など)。
  /// 画面は英語になり、訳の言語の既定は英語の語義になる。
  static bool isUnsupported(List<Locale>? preferred) =>
      _match(preferred) == null;

  /// 端末の優先言語を上から見て、最初に対応しているものを返す。無ければ null。
  static Locale? _match(List<Locale>? preferred) {
    for (final locale in preferred ?? const <Locale>[]) {
      switch (locale.languageCode) {
        case 'ja':
          return ja;
        case 'en':
          return en;
        case 'zh' when _isTraditional(locale):
          return zhHant;
        case 'es':
          return es;
        case 'fr':
          return fr;
      }
    }
    return null;
  }

  static bool _isTraditional(Locale locale) =>
      locale.scriptCode == 'Hant' ||
      (locale.scriptCode == null &&
          _traditionalRegions.contains(locale.countryCode));

  /// 訳の言語の既定。画面の言語と同じ訳の言語があればそれ、無ければ日本語
  /// (繁体字の画面なら繁体字、スペイン語の画面ならスペイン語)。
  ///
  /// 英語の画面になる利用者も日本語にするのは、今の利用者のほとんどが
  /// 日本語話者で(端末を英語にしている海外在住者を含む)、英語を英語で
  /// 訳すことはできないため。
  static TranslationLanguage defaultTranslationLanguage(Locale appLocale) =>
      switch (appLocale.languageCode) {
        'zh' => TranslationLanguage.zhHant,
        'es' => TranslationLanguage.es,
        'fr' => TranslationLanguage.fr,
        _ => TranslationLanguage.ja,
      };

  /// [preferred] の端末での訳の言語の既定。
  ///
  /// 対応外の言語の端末は英語の語義にする。どの訳の言語も利用者の言語では
  /// ないので、日本語などの訳を出すより英英の方が読める。英語の端末は
  /// [defaultTranslationLanguage] のとおり日本語のまま(海外在住の日本語話者)。
  static TranslationLanguage defaultTranslationLanguageFor(
    List<Locale>? preferred,
  ) => isUnsupported(preferred)
      ? TranslationLanguage.enDefinition
      : defaultTranslationLanguage(resolve(preferred));

  /// 設定に出す訳の言語の選択肢。
  ///
  /// 英語の語義は対応外の言語の端末と、すでに選んでいる利用者にだけ出す。
  /// 対応言語の端末の設定画面を今までと変えないため。
  static List<TranslationLanguage> translationLanguageChoices(
    List<Locale>? preferred,
    TranslationLanguage current,
  ) => [
    for (final language in TranslationLanguage.values)
      if (!language.usesDefinition ||
          current == language ||
          isUnsupported(preferred))
        language,
  ];

  /// この端末での訳の言語の選択肢(設定画面に出す)。
  static List<TranslationLanguage> deviceTranslationLanguageChoices(
    TranslationLanguage current,
  ) => translationLanguageChoices(PlatformDispatcher.instance.locales, current);

  /// この端末での訳の言語の既定(設定が未保存のときに使う)。
  static TranslationLanguage get deviceDefaultTranslationLanguage =>
      defaultTranslationLanguageFor(PlatformDispatcher.instance.locales);
}
