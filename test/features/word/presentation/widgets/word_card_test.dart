import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/word/presentation/widgets/word_card.dart';
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

  /// [platform] を装ってカードを 1 枚描画し、[body] にコンテキストメニュー
  /// 要求の記録先を渡す。
  ///
  /// `debugDefaultTargetPlatformOverride` は tearDown ではなくテスト本体の中で
  /// 戻す必要がある(flutter_test はテスト本体の直後に debug 変数が未設定へ
  /// 戻っていることを検証するため)。失敗時も必ず戻すよう finally で括る。
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
              body: WordCard(
                word: word,
                showIpa: true,
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
