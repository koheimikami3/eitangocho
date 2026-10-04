import 'package:eitangocho/app/app_route_observer.dart';
import 'package:eitangocho/features/ads/presentation/banner_ad_height_notifier.dart';
import 'package:eitangocho/features/ads/presentation/widgets/mobile_banner_ad.dart';
import 'package:eitangocho/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../ads_test_overrides.dart';
import '../../../purchase/purchase_test_overrides.dart';

/// 広告が読み込み済みの状態を装う。実際の [BannerAd] はプラグイン(ネイティブ)
/// が要るためテストでは作れないので、「高さが確定している」という結果だけを
/// 差し替える。
class _LoadedBannerAdHeight extends BannerAdHeight {
  @override
  double build() => 50;
}

void main() {
  /// [MobileBannerAd] を単体で描く。ルート監視の検証で使うため、実アプリと
  /// 同じ [appRouteObserver] を付けた [MaterialApp] に載せる。
  Future<void> pumpBanner(WidgetTester tester, {bool adLoaded = false}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adsDisabled,
          purchasesDisabled,
          if (adLoaded)
            bannerAdHeightProvider.overrideWith(_LoadedBannerAdHeight.new),
        ],
        child: MaterialApp(
          locale: const Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorObservers: [appRouteObserver],
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  const MobileBannerAd(),
                  TextButton(
                    // 実際に広告を覆うのは登録・編集シート(画面高の 88%)。
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      builder: (_) => const Text('シート'),
                    ),
                    child: const Text('開く'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // バナー自身はシートに覆われている間ツリーから外れるため、常に残っている
  // MaterialApp の context からコンテナを引く。
  double heightOf(WidgetTester tester) => ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(bannerAdHeightProvider);

  testWidgets('広告が無効なら枠ごと描かず、高さも 0 のまま', (tester) async {
    await pumpBanner(tester);

    expect(find.byType(AdWidget), findsNothing);
    // 空の枠(背景と境界線だけの帯)も出さない。
    expect(find.byType(Container), findsNothing);
    expect(heightOf(tester), 0);
  });

  testWidgets('上に別の画面が積まれると高さを 0 に戻す', (tester) async {
    await pumpBanner(tester, adLoaded: true);
    expect(heightOf(tester), 50);

    // 登録シートのように画面を覆うものが乗ると、広告は捨てて高さも返す
    // (見えていない広告のインプレッションを避けるため)。
    await tester.tap(find.text('開く'));
    await tester.pumpAndSettle();

    expect(heightOf(tester), 0);
  });
}
