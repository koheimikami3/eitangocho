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

  testWidgets('アイコンのみの形はラベルを持たず、幅 44pt × 高さ 30pt を占める', (tester) async {
    await pump(tester, MobilePronunciationButtonVariant.icon);

    expect(find.byType(Text), findsNothing);

    // 高さを 44pt にするとカードのフッタが間延びするため、行の高さに
    // 響かない幅だけ広げている(クラスのドキュメント参照)。
    final size = tester.getSize(find.byType(MobilePronunciationButton));
    expect(size.width, MobilePronunciationButton.minTapTarget);
    expect(size.height, MobilePronunciationButton.circleDiameter);
  });

  testWidgets('アイコンのみの形は円をタップ領域の右端に揃える', (tester) async {
    await pump(tester, MobilePronunciationButtonVariant.icon);

    // 中央寄せだと円の右端がコンテンツの右端より内側に入り、左端の
    // チェックボックスに対して左寄りに見える(クラスのドキュメント参照)。
    final tapTarget = tester.getRect(find.byType(MobilePronunciationButton));
    // 外側の Container は押下演出(MobilePressable)のもの。円は最も内側。
    final circle = tester.getRect(
      find
          .descendant(
            of: find.byType(MobilePronunciationButton),
            matching: find.byType(Container),
          )
          .last,
    );

    expect(circle.width, MobilePronunciationButton.circleDiameter);
    expect(circle.right, tapTarget.right);
  });

  testWidgets('クイズの形は「発音を聞く」を出し、高さ 36pt にする', (tester) async {
    await pump(tester, MobilePronunciationButtonVariant.pill);

    expect(find.text('発音を聞く'), findsOneWidget);
    expect(
      tester.getSize(find.byType(MobilePronunciationButton)).height,
      MobilePronunciationButton.pillHeight,
    );
  });

  testWidgets('文字色はライト / ダークで切り替わる', (tester) async {
    Color labelColor() => tester.widget<Text>(find.text('発音を聞く')).style!.color!;

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
