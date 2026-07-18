import 'package:eitangocho/utils/google_translate_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('単語を埋め込んだ Google 翻訳 URL を生成する', () {
    expect(
      googleTranslateUrl('serendipity').toString(),
      'https://translate.google.com/?sl=en&tl=ja&text=serendipity&op=translate',
    );
  });

  test('空白・記号は URL エンコードする', () {
    expect(
      googleTranslateUrl("coup d'état").toString(),
      'https://translate.google.com/?sl=en&tl=ja'
      "&text=coup%20d'%C3%A9tat&op=translate",
    );
  });
}
