import 'package:eitangocho/components/pronunciation_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, PronunciationLink link) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: link)),
    );
  }

  testWidgets('既定では「発音を確認 ↗」を表示する', (tester) async {
    await pump(tester, const PronunciationLink(word: 'apple'));

    expect(find.text('発音を確認 ↗'), findsOneWidget);
  });

  testWidgets('compact なら「↗」のみを表示する', (tester) async {
    await pump(tester, const PronunciationLink(word: 'apple', compact: true));

    expect(find.text('↗'), findsOneWidget);
    expect(find.text('発音を確認 ↗'), findsNothing);
  });
}
