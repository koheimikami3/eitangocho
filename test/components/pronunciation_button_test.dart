import 'package:eitangocho/components/pronunciation_button.dart';
import 'package:eitangocho/components/speaker_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    PronunciationButtonVariant variant,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PronunciationButton(word: 'apple', variant: variant),
          ),
        ),
      ),
    );
  }

  testWidgets('どの形でもスピーカーアイコンを出す', (tester) async {
    for (final variant in PronunciationButtonVariant.values) {
      await pump(tester, variant);
      expect(find.byType(SpeakerIcon), findsOneWidget, reason: variant.name);
    }
  });

  testWidgets('学習中カードは「発音」、クイズは「発音を聞く」を出す', (tester) async {
    await pump(tester, PronunciationButtonVariant.cardPill);
    expect(find.text('発音'), findsOneWidget);

    await pump(tester, PronunciationButtonVariant.quizPill);
    expect(find.text('発音を聞く'), findsOneWidget);
  });

  testWidgets('テーブルの発音列はラベルを持たず、正方形で Tooltip が付く', (tester) async {
    await pump(tester, PronunciationButtonVariant.tableIcon);

    expect(find.byType(Text), findsNothing);
    expect(find.byType(Tooltip), findsOneWidget);

    final size = tester.getSize(find.byType(PronunciationButton));
    expect(size.width, size.height);
    expect(size.height, PronunciationButtonVariant.tableIcon.height);
  });

  testWidgets('ラベル付きの形には Tooltip を付けない(文言で用途が分かるため)', (tester) async {
    await pump(tester, PronunciationButtonVariant.cardPill);

    expect(find.byType(Tooltip), findsNothing);
  });

  testWidgets('高さはデザインの値どおりに出し分ける', (tester) async {
    for (final variant in PronunciationButtonVariant.values) {
      await pump(tester, variant);
      expect(
        tester.getSize(find.byType(PronunciationButton)).height,
        variant.height,
        reason: variant.name,
      );
    }
  });
}
