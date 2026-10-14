import 'package:eitangocho/components/mobile_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<FocusNode> pumpSheet(WidgetTester tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MobileSheet(
            title: '単語を登録',
            leftLabel: 'キャンセル',
            onLeft: () {},
            child: Column(
              children: [
                TextField(focusNode: focusNode),
                const SizedBox(height: 300),
              ],
            ),
          ),
        ),
      ),
    );
    return focusNode;
  }

  testWidgets('入力欄の外をタップするとフォーカスが外れる', (tester) async {
    final focusNode = await pumpSheet(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    // 入力欄の下の何も無いところ。
    await tester.tapAt(
      tester.getBottomLeft(find.byType(TextField)) + const Offset(10, 100),
    );
    await tester.pump();

    expect(focusNode.hasFocus, isFalse);
  });

  testWidgets('入力欄自体をタップしてもフォーカスは外れない', (tester) async {
    final focusNode = await pumpSheet(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();

    await tester.tap(find.byType(TextField));
    await tester.pump();

    expect(focusNode.hasFocus, isTrue);
  });

  // フォームの下の欄を見に行くスクロールで閉じないこと(onTapOutside を使わない理由)。
  testWidgets('入力欄の外をドラッグしてもフォーカスは外れない', (tester) async {
    final focusNode = await pumpSheet(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();

    await tester.dragFrom(
      tester.getBottomLeft(find.byType(TextField)) + const Offset(10, 100),
      const Offset(0, -80),
    );
    await tester.pump();

    expect(focusNode.hasFocus, isTrue);
  });
}
