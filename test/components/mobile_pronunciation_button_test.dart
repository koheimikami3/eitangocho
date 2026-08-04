import 'package:eitangocho/components/mobile_pronunciation_button.dart';
import 'package:eitangocho/components/speaker_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    MobilePronunciationButtonVariant variant, {
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Scaffold(
          body: Center(
            child: MobilePronunciationButton(word: 'apple', variant: variant),
          ),
        ),
      ),
    );
  }

  testWidgets('どの形でもスピーカーアイコンを出す', (tester) async {
    for (final variant in MobilePronunciationButtonVariant.values) {
      await pump(tester, variant);
      expect(find.byType(SpeakerIcon), findsOneWidget, reason: variant.name);
    }
  });

  testWidgets('アイコンのみの形はラベルを持たず、44pt 四方のタップ領域を確保する', (tester) async {
    await pump(tester, MobilePronunciationButtonVariant.icon);

    expect(find.byType(Text), findsNothing);

    final size = tester.getSize(find.byType(MobilePronunciationButton));
    expect(size.width, MobilePronunciationButton.minTapTarget);
    expect(size.height, MobilePronunciationButton.minTapTarget);
  });

  testWidgets('クイズの形は「発音を聞く」を出し、高さ 44pt を確保する', (tester) async {
    await pump(tester, MobilePronunciationButtonVariant.pill);

    expect(find.text('発音を聞く'), findsOneWidget);
    expect(
      tester.getSize(find.byType(MobilePronunciationButton)).height,
      MobilePronunciationButton.minTapTarget,
    );
  });

  testWidgets('文字色はライト / ダークで切り替わる', (tester) async {
    Color labelColor() => tester
        .widget<Text>(find.text('発音を聞く'))
        .style!
        .color!;

    await pump(tester, MobilePronunciationButtonVariant.pill);
    final light = labelColor();

    await pump(
      tester,
      MobilePronunciationButtonVariant.pill,
      brightness: Brightness.dark,
    );
    await tester.pumpAndSettle();

    expect(labelColor(), isNot(light));
  });
}
