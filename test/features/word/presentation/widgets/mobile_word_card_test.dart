import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/enums/part_of_speech.dart';
import 'package:eitangocho/features/word/presentation/widgets/mobile_word_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final word = Word(
    id: 1,
    word: 'apple',
    ipa: '/ˈæp.əl/',
    japanese: 'りんご',
    partsOfSpeech: const [PartOfSpeech.noun],
    exampleEn: '',
    exampleJa: '',
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
  }) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: singleColumn ? 370 : 185,
            child: MobileWordCard(
              word: word.copyWith(
                partsOfSpeech: partsOfSpeech,
                exampleEn: exampleEn,
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

  testWidgets('2 列では単語の下に IPA と品詞が並び、品詞は右端に寄る', (tester) async {
    await pumpCard(tester, singleColumn: false, showIpa: true);

    final wordRect = tester.getRect(find.text('apple'));
    final ipaRect = tester.getRect(find.text('/ˈæp.əl/'));
    final badgeRect = tester.getRect(find.text('名詞'));

    // IPA と品詞は単語より下の同じ行にある。
    expect(ipaRect.top, greaterThan(wordRect.bottom - 1));
    expect(badgeRect.center.dy, closeTo(ipaRect.center.dy, 6));
    // 品詞は IPA より右で、カードの右端(padding 13 + バッジの内側 7)に寄る。
    expect(badgeRect.left, greaterThan(ipaRect.right));
    expect(badgeRect.right, closeTo(cardRight(tester) - 13 - 7, 1));
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

  testWidgets('2 列で品詞が長いと、IPA を潰さず品詞を次の行に落とす', (tester) async {
    // 品詞 3 つ分のバッジは IPA と同じ行に収まらない幅になる。
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
    // 品詞は IPA の下の行に左寄せで並ぶ。
    expect(badgeRect.top, greaterThan(ipaRect.bottom - 1));
    expect(badgeRect.left, closeTo(ipaRect.left + 7, 1));
  });

  testWidgets('英例文の行数は 2 列で 3 行、1 列で 2 行に固定される', (tester) async {
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
      final lines = singleColumn ? 2 : 3;

      expect(text.maxLines, lines);
      // 行数分の高さ(12 * 1.45 * 行数)が確保される。
      expect(rect.height, closeTo(12 * 1.45 * lines, 1));
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
