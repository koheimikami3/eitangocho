import 'package:eitangocho/components/pronunciation_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, PronunciationButton button) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: Scaffold(body: button)),
      ),
    );
  }

  testWidgets('audioUrl があれば円形の再生ボタンを表示する', (tester) async {
    await pump(
      tester,
      const PronunciationButton(
        word: 'apple',
        audioUrl: 'https://example.com/a.mp3',
      ),
    );

    expect(find.byIcon(Icons.volume_up), findsOneWidget);
    expect(find.text('発音を確認 ↗'), findsNothing);
  });

  testWidgets('audioUrl が空ならリンクを表示する', (tester) async {
    await pump(
      tester,
      const PronunciationButton(word: 'apple', audioUrl: ''),
    );

    expect(find.text('発音を確認 ↗'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up), findsNothing);
  });

  testWidgets('compactLink なら「↗」のみを表示する', (tester) async {
    await pump(
      tester,
      const PronunciationButton(
        word: 'apple',
        audioUrl: '',
        compactLink: true,
      ),
    );

    expect(find.text('↗'), findsOneWidget);
    expect(find.text('発音を確認 ↗'), findsNothing);
  });
}
