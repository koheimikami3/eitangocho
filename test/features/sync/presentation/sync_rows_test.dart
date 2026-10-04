import 'package:eitangocho/constants/app_colors.dart';
import 'package:eitangocho/features/settings/presentation/widgets/settings_card.dart';
import 'package:eitangocho/features/sync/data/sync_notifier.dart';
import 'package:eitangocho/features/sync/domain/cloud_file_store.dart';
import 'package:eitangocho/features/sync/domain/sync_state.dart';
import 'package:eitangocho/features/sync/presentation/desktop_sync_rows.dart';
import 'package:eitangocho/features/sync/presentation/mobile_sync_rows.dart';
import 'package:eitangocho/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// 状態を固定するだけの SyncNotifier。build() ごと差し替えるので、
/// 保存値の復元も iCloud への接続も走らない。
class _FixedSyncNotifier extends SyncNotifier {
  _FixedSyncNotifier(this.fixed);

  final SyncState fixed;

  @override
  SyncState build() => fixed;
}

void main() {
  // build() は差し替えても SyncNotifier のフィールド初期化
  // (SharedPreferencesAsync)は走るため、保存先を用意しておく。
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Future<void> pump(WidgetTester tester, SyncState state, Widget rows) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [syncProvider.overrideWith(() => _FixedSyncNotifier(state))],
        child: MaterialApp(
          locale: const Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SettingsCard(children: [rows])),
        ),
      ),
    );
    await tester.pump();
  }

  final rowsByPlatform = {
    'iOS': const MobileSyncRows(),
    'macOS': const DesktopSyncRows(),
  };

  for (final entry in rowsByPlatform.entries) {
    final platform = entry.key;
    final rows = entry.value;

    testWidgets('$platform: 同期が無効なら「今すぐ同期」行を出さない', (tester) async {
      await pump(tester, const SyncState(), rows);

      expect(find.text('iCloud 同期'), findsOneWidget);
      expect(find.text('今すぐ同期'), findsNothing);
    });

    // 説明文をカードの外に置くと書き出し / 読み込みの行が間に挟まるため、
    // 状態は「今すぐ同期」行の右端に出している。
    testWidgets('$platform: 最終同期の日時は「今すぐ同期」行に並べる', (tester) async {
      await pump(
        tester,
        SyncState(enabled: true, lastSyncedAt: DateTime(2026, 8, 14, 22, 30)),
        rows,
      );

      expect(find.text('今すぐ同期'), findsOneWidget);
      expect(find.text('最終同期: 2026/08/14 22:30'), findsOneWidget);
    });

    testWidgets('$platform: まだ同期していなければその旨を出す', (tester) async {
      await pump(tester, const SyncState(enabled: true), rows);

      expect(find.text('まだ同期していません'), findsOneWidget);
    });

    // エラーは右端に収まらない長さになるため、行を分けて赤字で出す。
    testWidgets('$platform: 同期エラーは独立した行に赤字で出す', (tester) async {
      const message = 'iCloud が利用できません。設定で iCloud Drive にサインインしてください。';
      await pump(
        tester,
        const SyncState(
          enabled: true,
          failure: SyncFailure(reason: CloudFailureReason.noICloud),
        ),
        rows,
      );

      final text = tester.widget<Text>(find.text(message));
      expect(text.style?.color, AppColors.danger);
    });
  }
}
