import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/features/analytics/data/analytics_client.dart';
import 'package:eitangocho/features/purchase/presentation/widgets/mobile_pro_link.dart';
import 'package:eitangocho/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../analytics/fake_analytics_client.dart';

void main() {
  // 置き場所(クイズ結果の広告の下)は広告が読み込めたときにしか描かれず、
  // テストでは広告を読み込めないため、リンク単体で確かめる。
  testWidgets('押すと設定タブに切り替え、pro_link_tapped を送る', (tester) async {
    final analytics = FakeAnalyticsClient();
    final container = ProviderContainer(
      overrides: [analyticsClientProvider.overrideWithValue(analytics)],
    );
    addTearDown(container.dispose);
    // 本番ではシェルが常に購読している。購読しないと自動破棄で選択が消える。
    final subscription = container.listen(mainPageProvider, (_, _) {});
    addTearDown(subscription.close);
    container.read(mainPageProvider.notifier).selectView(MainView.quiz);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: MobileProLink()),
        ),
      ),
    );

    await tester.tap(find.text('コーヒー1杯の差し入れで広告が消えます ☕'));
    // 押下演出のアニメーションを終わらせる(残すと Timer が残って失敗する)。
    await tester.pumpAndSettle();

    expect(container.read(mainPageProvider).view, MainView.settings);
    expect(analytics.eventsNamed('pro_link_tapped'), hasLength(1));
  });
}
