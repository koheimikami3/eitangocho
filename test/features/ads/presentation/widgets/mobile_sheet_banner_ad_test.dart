import 'package:eitangocho/features/ads/presentation/widgets/mobile_ad_slot.dart';
import 'package:eitangocho/features/ads/presentation/widgets/mobile_sheet_banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ads_test_overrides.dart';

void main() {
  /// [keyboardHeight] を装ってシート内バナーを描く。実際のキーボードは
  /// MediaQuery の viewInsets.bottom として届く。
  Future<void> pumpBanner(WidgetTester tester, double keyboardHeight) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [adsDisabled],
        child: MaterialApp(
          // Scaffold を挟まないのは、body に渡す MediaQuery から
          // viewInsets.bottom を取り除いてしまうため(実際の置き場所は
          // ボトムシートの中で、キーボードの高さがそのまま届く)。
          home: MediaQuery(
            data: MediaQueryData(
              viewInsets: EdgeInsets.only(bottom: keyboardHeight),
            ),
            child: const Material(child: MobileSheetBannerAd()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('キーボードが出ていなければ広告枠を組み立てる', (tester) async {
    await pumpBanner(tester, 0);

    // 広告そのものは読み込めない(プラグインが無い)が、枠は生きている。
    expect(find.byType(MobileAdSlot), findsOneWidget);
  });

  testWidgets('キーボードが出ている間は枠ごと出さない', (tester) async {
    await pumpBanner(tester, 300);

    // 入力欄とキーボードの間に広告が挟まると誤タップを誘発するため。
    expect(find.byType(MobileAdSlot), findsNothing);
  });
}
