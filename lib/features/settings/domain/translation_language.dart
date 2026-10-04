import 'package:eitangocho/l10n/app_localizations.dart';

/// 訳の言語。単語の訳語・例文の訳を何語で取得し保存するかを決める。
///
/// 画面の表示言語(AppLocalizations)とは別に持つ。英語の画面で日本語の訳を
/// 使う利用者(海外在住の日本語話者など)がいるため。既定は端末の言語から
/// 決め(`defaultTranslationLanguage`)、設定で変えられる。
///
/// 取得元ごとの言語コードもここに集める。言語を足すときは値を 1 つ足し、
/// 各コードを埋めれば取得の経路が揃う(docs/design.md「多言語化」)。
enum TranslationLanguage {
  ja(
    storageCode: 'ja',
    kaikkiLangCode: 'ja',
    tatoebaLang: 'jpn',
    deeplTargetLang: 'JA',
    googleTranslateCode: 'ja',
  ),
  zhHant(
    storageCode: 'zh-Hant',
    kaikkiLangCode: 'cmn',
    tatoebaLang: 'cmn',
    tatoebaScript: 'Hant',
    deeplTargetLang: 'ZH-HANT',
    googleTranslateCode: 'zh-TW',
  );

  const TranslationLanguage({
    required this.storageCode,
    required this.kaikkiLangCode,
    required this.tatoebaLang,
    this.tatoebaScript,
    required this.deeplTargetLang,
    required this.googleTranslateCode,
  });

  /// words.translation_language と同期 JSON に保存する値(BCP 47)。
  final String storageCode;

  /// kaikki の訳語の `lang_code`。中国語は北京語(cmn)の訳語を使う。
  final String kaikkiLangCode;

  /// Tatoeba の言語コード(ISO 639-3)。
  final String tatoebaLang;

  /// Tatoeba の訳の文字体系。中国語は繁体字と簡体字が同じ cmn に混ざるため
  /// これで絞る。null なら絞らない。
  final String? tatoebaScript;

  /// DeepL の target_lang。
  final String deeplTargetLang;

  /// 発音確認で開く Google 翻訳の訳先(`tl`)。
  final String googleTranslateCode;

  /// 設定の選択肢に出す名前(「中国語(繁体字)」など)。
  String label(AppLocalizations l10n) => l10n.translationLanguageName(name);

  /// 項目名や出題方向に差し込む短い名前(「日本語訳」の「日本語」)。
  String shortLabel(AppLocalizations l10n) =>
      l10n.translationLanguageShortName(name);

  /// 保存値から引く。未知・欠落(古い版のデータ)は日本語として扱う。
  static TranslationLanguage fromStorageCode(String? code) =>
      values.where((l) => l.storageCode == code).firstOrNull ?? ja;
}
