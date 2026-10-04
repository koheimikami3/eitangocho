import 'package:eitangocho/features/settings/domain/translation_language.dart';
import 'package:eitangocho/utils/app_locale.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolve', () {
    test('日本語の端末は日本語', () {
      expect(AppLocale.resolve(const [Locale('ja', 'JP')]), AppLocale.ja);
    });

    test('文字体系が Hant の中国語は繁体字', () {
      expect(
        AppLocale.resolve(const [
          Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'TW',
          ),
        ]),
        AppLocale.zhHant,
      );
    });

    test('文字体系の無い zh-TW / zh-HK も繁体字', () {
      expect(AppLocale.resolve(const [Locale('zh', 'TW')]), AppLocale.zhHant);
      expect(AppLocale.resolve(const [Locale('zh', 'HK')]), AppLocale.zhHant);
    });

    test('簡体字は対応言語として扱わず、次の候補へ進む', () {
      const hans = Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
        countryCode: 'CN',
      );
      expect(AppLocale.resolve(const [hans]), AppLocale.en);
      expect(AppLocale.resolve(const [hans, Locale('ja')]), AppLocale.ja);
    });

    test('対応外の言語は英語。優先言語の後ろに対応言語があればそれを採る', () {
      expect(AppLocale.resolve(const [Locale('ko', 'KR')]), AppLocale.en);
      expect(
        AppLocale.resolve(const [Locale('ko'), Locale('ja')]),
        AppLocale.ja,
      );
      expect(AppLocale.resolve(null), AppLocale.en);
    });
  });

  test('訳の言語の既定は、繁体字の画面だけ繁体字、それ以外は日本語', () {
    expect(
      AppLocale.defaultTranslationLanguage(AppLocale.zhHant),
      TranslationLanguage.zhHant,
    );
    expect(
      AppLocale.defaultTranslationLanguage(AppLocale.ja),
      TranslationLanguage.ja,
    );
    // 英語の画面(対応外の言語の端末・英語設定の日本語話者)も日本語。
    expect(
      AppLocale.defaultTranslationLanguage(AppLocale.en),
      TranslationLanguage.ja,
    );
  });
}
