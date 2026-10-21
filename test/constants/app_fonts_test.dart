import 'package:eitangocho/constants/app_fonts.dart';
import 'package:eitangocho/utils/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFonts.cjkFallback', () {
    test('繁体字の画面は繁体字フォントを先にする', () {
      expect(AppFonts.cjkFallback(AppLocale.zhHant), [
        'NotoSansTC',
        'NotoSansJP',
      ]);
    });

    test('繁体字以外の画面は和文フォントを先にする', () {
      for (final locale in [
        AppLocale.ja,
        AppLocale.en,
        AppLocale.es,
        AppLocale.fr,
      ]) {
        expect(AppFonts.cjkFallback(locale), [
          'NotoSansJP',
          'NotoSansTC',
        ], reason: '$locale');
      }
    });
  });

  group('AppFonts.isCjk', () {
    test('日本語・繁体字の画面だけ true', () {
      expect(AppFonts.isCjk(AppLocale.ja), isTrue);
      expect(AppFonts.isCjk(AppLocale.zhHant), isTrue);
      expect(AppFonts.isCjk(AppLocale.en), isFalse);
      expect(AppFonts.isCjk(AppLocale.es), isFalse);
      expect(AppFonts.isCjk(AppLocale.fr), isFalse);
    });
  });
}
