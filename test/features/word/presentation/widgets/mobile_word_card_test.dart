import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_shrinking_ipa_text.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_word_card.dart';
import 'package:eitangocho/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final word = Word(
    id: 1,
    word: 'apple',
    ipa: '/ˈæp.əl/',
    meaning: 'りんご',
    partsOfSpeech: const [PartOfSpeech.noun],
    exampleEn: '',
    exampleTranslation: '',
    audioUrl: '',
    isLearned: false,
    correctCount: 0,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  /// カードを 1 枚描画する。幅は 2 列時のカード幅相当(iPhone の論理幅の半分)。
  Future<void> pumpCard(
    WidgetTester tester, {
    required bool singleColumn,
    required bool showIpa,
    List<PartOfSpeech> partsOfSpeech = const [PartOfSpeech.noun],
    String exampleEn = '',
    String? ipa,
  }) => tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ja'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: singleColumn ? 370 : 185,
            child: MobileWordCard(
              word: word.copyWith(
                partsOfSpeech: partsOfSpeech,
                exampleEn: exampleEn,
                ipa: ipa ?? word.ipa,
              ),
              showIpa: showIpa,
              singleColumn: singleColumn,
              onToggleLearned: (_) {},
              onTap: () {},
            ),
          ),
        ),
      ),
    ),
  );

  /// カード外形の右端。品詞バッジが右に寄っているかの基準にする。
  double cardRight(WidgetTester tester) =>
      tester.getRect(find.byType(MobileWordCard)).right;

  // 収まるときだけ同じ行に並べると、単語ごとにヘッダが 2 行にも 3 行にも
  // なって並びが揃わないため、長さに関わらず 1 項目 1 行にする。
  testWidgets('2 列では単語・IPA・品詞をそれぞれ別の行に積む', (tester) async {
    await pumpCard(tester, singleColumn: false, showIpa: true);

    final wordRect = tester.getRect(find.text('apple'));
    final ipaRect = tester.getRect(find.text('/ˈæp.əl/'));
    final badgeRect = tester.getRect(find.text('名詞'));

    expect(ipaRect.top, greaterThan(wordRect.bottom - 1));
    expect(badgeRect.top, greaterThan(ipaRect.bottom - 1));
    // 3 つとも左端が揃う(バッジの内側パディング 7px 分だけずれる)。
    expect(ipaRect.left, closeTo(wordRect.left, 1));
    expect(badgeRect.left, closeTo(wordRect.left + 7, 1));
  });

  testWidgets('2 列で IPA が非表示なら品詞は左寄せになる', (tester) async {
    await pumpCard(tester, singleColumn: false, showIpa: false);

    final wordRect = tester.getRect(find.text('apple'));
    final badgeRect = tester.getRect(find.text('名詞'));

    expect(find.text('/ˈæp.əl/'), findsNothing);
    expect(badgeRect.top, greaterThan(wordRect.bottom - 1));
    // 単語と同じ左端から始まる(バッジの内側パディング 7px 分だけずれる)。
    expect(badgeRect.left, closeTo(wordRect.left + 7, 1));
  });

  testWidgets('2 列では品詞が長くても IPA は潰れない', (tester) async {
    await pumpCard(
      tester,
      singleColumn: false,
      showIpa: true,
      partsOfSpeech: const [
        PartOfSpeech.noun,
        PartOfSpeech.verb,
        PartOfSpeech.adjective,
      ],
    );

    final ipa = tester.renderObject<RenderBox>(find.text('/ˈæp.əl/'));
    final ipaRect = tester.getRect(find.text('/ˈæp.əl/'));
    final badgeRect = tester.getRect(find.text('名詞・動詞・形容詞'));

    // IPA は 1 行のまま(幅を削られて折り返していない)。
    expect(ipa.size.height, lessThan(20));
    expect(badgeRect.top, greaterThan(ipaRect.bottom - 1));
    expect(badgeRect.left, closeTo(ipaRect.left + 7, 1));
  });

  // 長い IPA は折り返さず字を縮めて 1 行に収める(折り返すとカードごとに
  // ヘッダの高さが変わり、2 列に並べたとき単語の位置が揃わない)。
  testWidgets('2 列で幅に収まらない IPA は縮めて 1 行に収める', (tester) async {
    const longIpa = '/ˌɪntəˌnæʃənəlaɪˈzeɪʃən/';
    await pumpCard(tester, singleColumn: false, showIpa: true, ipa: longIpa);

    final text = tester.widget<Text>(find.text(longIpa));
    final rect = tester.getRect(find.text(longIpa));

    expect(text.style!.fontSize, lessThan(MobileShrinkingIpaText.maxFontSize));
    expect(
      text.style!.fontSize,
      greaterThanOrEqualTo(MobileShrinkingIpaText.minFontSize),
    );
    // 1 行に収まっている(11px の行送りを 1 行分だけ使う)。
    expect(rect.height, lessThan(MobileShrinkingIpaText.maxFontSize * 2));
  });

  testWidgets('収まる IPA は縮めない', (tester) async {
    await pumpCard(tester, singleColumn: false, showIpa: true);

    final text = tester.widget<Text>(find.text('/ˈæp.əl/'));

    expect(text.style!.fontSize, MobileShrinkingIpaText.maxFontSize);
  });

  testWidgets('英例文の行数は列数によらず 2 行に固定される', (tester) async {
    const example =
        'She ate an apple every morning before walking to the station '
        'with her younger brother.';

    for (final singleColumn in [false, true]) {
      await pumpCard(
        tester,
        singleColumn: singleColumn,
        showIpa: true,
        exampleEn: example,
      );

      final text = tester.widget<Text>(find.text(example));
      final rect = tester.getRect(find.text(example));

      expect(text.maxLines, 2);
      // 2 行分の高さ(12 * 1.45 * 2)が確保される。
      expect(rect.height, closeTo(12 * 1.45 * 2, 1));
    }
  });

  testWidgets('1 列では単語・IPA・品詞が同じ行に並ぶ', (tester) async {
    await pumpCard(tester, singleColumn: true, showIpa: true);

    final wordRect = tester.getRect(find.text('apple'));
    final ipaRect = tester.getRect(find.text('/ˈæp.əl/'));
    final badgeRect = tester.getRect(find.text('名詞'));

    // 3 つとも同じ行(単語の高さの範囲に収まる)。
    expect(ipaRect.center.dy, closeTo(wordRect.center.dy, 6));
    expect(badgeRect.center.dy, closeTo(wordRect.center.dy, 6));
    // 左から 単語 → IPA → 品詞 の順で、品詞は右端に寄る。
    expect(ipaRect.left, greaterThan(wordRect.right));
    expect(badgeRect.left, greaterThan(ipaRect.right));
    expect(badgeRect.right, closeTo(cardRight(tester) - 13 - 7, 1));
  });
}
