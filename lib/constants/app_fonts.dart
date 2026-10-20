import 'dart:ui';

/// 同梱フォントのファミリー名(pubspec.yaml の fonts と一致させる)。
///
/// 欧文は Inter をテーマで全体に当て、Inter に無い漢字・かなは
/// [cjkFallback] の順に探す。発音記号だけは IPA 用に作られた Andika を
/// 個別に指定する。
abstract final class AppFonts {
  static const sans = 'Inter';
  static const ipa = 'Andika';

  /// 漢字・かなの字面の下端がベースラインより下に出る量(文字の大きさに対する比)。
  /// Noto Sans JP / TC の字面の枠の下端(OS/2 typo の -120 / 1000)。
  static const cjkEmBoxDescent = 0.12;

  static const _japanese = 'NotoSansJP';
  static const _traditionalChinese = 'NotoSansTC';

  /// 和文・繁体字フォントの優先順。
  ///
  /// 漢字はどちらのフォントにも入っているので、先頭のフォントの字形で出る。
  /// 繁体字の画面で日本の字形を出さないよう、表示言語で先頭を入れ替える。
  /// 繁体字以外の画面(英・西・仏を含む)は和文を先にする。訳の言語の既定が
  /// 日本語になるため(AppLocale.defaultTranslationLanguage)。
  static List<String> cjkFallback(Locale locale) => locale.languageCode == 'zh'
      ? const [_traditionalChinese, _japanese]
      : const [_japanese, _traditionalChinese];

  /// 画面の文字が漢字・かなになる表示言語か(日本語・繁体字)。
  static bool isCjk(Locale locale) =>
      locale.languageCode == 'ja' || locale.languageCode == 'zh';
}
