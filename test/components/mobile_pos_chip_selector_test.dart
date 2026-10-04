import 'package:eitangocho/components/mobile_pos_chip_selector.dart';
import 'package:eitangocho/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// iPhone の入力欄と同程度の幅(390pt の画面から左右の余白を引いた分)で置く。
  Future<void> pumpSelector(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 350,
              child: MobilePosChipSelector(
                selected: const {},
                onToggle: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  Finder chipOf(String label) => find
      .ancestor(of: find.text(label), matching: find.byType(AnimatedContainer))
      .first;

  double topOf(WidgetTester tester, String label) =>
      tester.getTopLeft(find.text(label)).dy;

  testWidgets('日本語は 5 つを 1 行に並べる', (tester) async {
    await pumpSelector(tester, const Locale('ja'));

    expect(topOf(tester, '名詞'), topOf(tester, 'その他'));
  });

  testWidgets('英語は adjective が入り切らないので 3 + 2 の 2 段にする', (tester) async {
    await pumpSelector(tester, const Locale('en'));

    expect(topOf(tester, 'noun'), topOf(tester, 'adjective'));
    expect(topOf(tester, 'adverb'), greaterThan(topOf(tester, 'adjective')));
    expect(topOf(tester, 'adverb'), topOf(tester, 'other'));
    // 2 段目も 1 段目と同じ幅で、左端をそろえる。
    final noun = tester.getRect(chipOf('noun'));
    final adverb = tester.getRect(chipOf('adverb'));
    expect(adverb.left, noun.left);
    expect(adverb.width, noun.width);
  });
}
