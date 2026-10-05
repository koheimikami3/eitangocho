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

  // 1 行に並べると長い単語が省略されて読めないため、1 項目 1 行に積む。
  testWidgets('単語・IPA・品詞をそれぞれ別の行に積み、長い単語も省略しない', (tester) async {
    const longWord = 'be well versed in something';
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                // 学習中グリッドのカード最小幅相当。
                width: 260,
                child: WordCard(
                  word: word.copyWith(word: longWord),
                  showIpa: true,
                  onToggleLearned: (_) {},
                  onTap: () {},
                  onContextMenu: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final wordRect = tester.getRect(find.text(longWord));
    final ipaRect = tester.getRect(find.text('/ˈæp.əl/'));
    final badgeRect = tester.getRect(find.text('その他'));

    // 1 行に収まらない長さなので、省略されず 2 行以上に折り返している。
    expect(wordRect.height, greaterThan(17 * 1.5));
    expect(ipaRect.top, greaterThan(wordRect.bottom - 1));
    expect(badgeRect.top, greaterThan(ipaRect.bottom - 1));
    expect(ipaRect.left, closeTo(wordRect.left, 1));
  });

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
