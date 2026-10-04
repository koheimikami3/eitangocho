import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/presentation/widgets/word_table_row.dart';
import 'package:eitangocho/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show kSecondaryButton;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final word = Word(
    id: 1,
    word: 'apple',
    ipa: '/ˈæp.əl/',
    meaning: 'りんご',
    partsOfSpeech: const [],
    exampleEn: '',
    exampleTranslation: '',
    translationLanguage: 'ja',
    audioUrl: '',
    isLearned: false,
    correctCount: 0,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  /// [platform] を装って 1 行だけ描画し、[body] にコンテキストメニュー要求の
  /// 記録先を渡す。debug 変数の後始末は word_card_test.dart と同じ理由で
  /// テスト本体の中(finally)で行う。
  Future<void> runForPlatform(
    WidgetTester tester,
    TargetPlatform platform,
    Future<void> Function(List<Offset> requests) body,
  ) async {
    debugDefaultTargetPlatformOverride = platform;
    try {
      final requests = <Offset>[];
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('ja'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: WordTableRow(
                word: word,
                onToggleLearned: (_) {},
                onTap: () {},
                onContextMenu: requests.add,
              ),
            ),
          ),
        ),
      );
      await body(requests);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  // 削除導線は iOS では編集シート内の「この単語を削除...」に一本化した
  // (デザイン準拠)。長押しメニューはどちらのプラットフォームでも持たない。
  for (final platform in [TargetPlatform.macOS, TargetPlatform.iOS]) {
    testWidgets('$platform では長押しではコンテキストメニューを要求しない', (tester) async {
      await runForPlatform(tester, platform, (requests) async {
        await tester.longPress(find.text('apple'));
        await tester.pump();

        expect(requests, isEmpty);
      });
    });
  }

  for (final platform in [TargetPlatform.macOS, TargetPlatform.iOS]) {
    testWidgets('$platform では右クリックでコンテキストメニューを要求する', (tester) async {
      await runForPlatform(tester, platform, (requests) async {
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('apple')),
          buttons: kSecondaryButton,
        );
        await gesture.up();
        await tester.pump();

        expect(requests, hasLength(1));
      });
    });
  }
}
