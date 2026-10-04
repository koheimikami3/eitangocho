import 'package:eitangocho/components/mobile_labeled_field.dart';
import 'package:eitangocho/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<TextField> pumpField(
    WidgetTester tester, {
    bool asciiOnly = false,
    int? minLines,
    int? maxLines = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MobileLabeledField(
            label: '英単語 *',
            controller: TextEditingController(),
            asciiOnly: asciiOnly,
            minLines: minLines,
            maxLines: maxLines,
          ),
        ),
      ),
    );
    return tester.widget<TextField>(find.byType(TextField));
  }

  // ASCII キーボードを出せる TextInputType は visiblePassword だけなので、
  // 別の型に書き換えられていないことをここで固定する(Flutter の
  // ToUIKeyboardType が UIKeyboardTypeASCIICapable に写すのはこれのみ)。
  testWidgets('asciiOnly は visiblePassword で ASCII キーボードに固定する', (tester) async {
    final field = await pumpField(tester, asciiOnly: true);

    expect(field.keyboardType, TextInputType.visiblePassword);
    expect(field.autocorrect, isFalse);
    expect(field.enableSuggestions, isFalse);
  });

  // TextField は keyboardType 未指定のとき行数から既定を決める(1 行なら text)。
  testWidgets('既定では通常キーボードのままで補正も切らない', (tester) async {
    final field = await pumpField(tester);

    expect(field.keyboardType, TextInputType.text);
    expect(field.autocorrect, isTrue);
    expect(field.enableSuggestions, isTrue);
  });

  testWidgets('maxLines: null で内容に応じて伸びる欄になる', (tester) async {
    final field = await pumpField(tester, minLines: 2, maxLines: null);

    expect(field.minLines, 2);
    expect(field.maxLines, isNull);
  });
}
