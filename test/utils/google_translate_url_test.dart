import 'package:eitangocho/features/settings/domain/translation_language.dart';
import 'package:eitangocho/utils/google_translate_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('単語を埋め込んだ Google 翻訳 URL を生成する', () {
    expect(
      googleTranslateUrl('serendipity', TranslationLanguage.ja).toString(),
      'https://translate.google.com/?sl=en&tl=ja&text=serendipity&op=translate',
    );
  });

  test('空白・記号は URL エンコードする', () {
    expect(
      googleTranslateUrl("coup d'état", TranslationLanguage.ja).toString(),
      'https://translate.google.com/?sl=en&tl=ja'
      "&text=coup%20d'%C3%A9tat&op=translate",
    );
  });

  test('訳先は訳の言語に合わせる(繁体字は zh-TW)', () {
    expect(
      googleTranslateUrl('apple', TranslationLanguage.zhHant).toString(),
      'https://translate.google.com/?sl=en&tl=zh-TW&text=apple&op=translate',
    );
  });
}
