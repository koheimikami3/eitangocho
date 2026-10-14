import 'package:eitangocho/components/mobile_labeled_field.dart';
import 'package:eitangocho/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<TextField> pumpField(
    WidgetTester tester, {
    bool asciiKeyboard = false,
    bool correction = true,
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
            asciiKeyboard: asciiKeyboard,
            correction: correction,
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
  testWidgets('asciiKeyboard は visiblePassword で ASCII キーボードに固定する', (
    tester,
  ) async {
    final field = await pumpField(tester, asciiKeyboard: true);

    expect(field.keyboardType, TextInputType.visiblePassword);
  });

  // 英例文欄は英字キーボードでも補正を残す。キーボードと補正は独立に指定する。
  testWidgets('asciiKeyboard だけなら補正は切らない', (tester) async {
    final field = await pumpField(tester, asciiKeyboard: true);

    expect(field.autocorrect, isTrue);
    expect(field.enableSuggestions, isTrue);
  });

  testWidgets('correction: false で補正と変換候補を切る', (tester) async {
    final field = await pumpField(
      tester,
      asciiKeyboard: true,
      correction: false,
    );

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

  testWidgets('英字キーボードの複数行の欄でも Return キーで改行できる', (tester) async {
    final field = await pumpField(
      tester,
      asciiKeyboard: true,
      minLines: 2,
      maxLines: null,
    );

    expect(field.keyboardType, TextInputType.visiblePassword);
    expect(field.textInputAction, TextInputAction.newline);
  });

  testWidgets('英字キーボードの 1 行の欄は Return キーの既定を変えない', (tester) async {
    final field = await pumpField(tester, asciiKeyboard: true);

    expect(field.textInputAction, isNull);
  });
}
