import 'dart:async';

import 'package:eitangocho/app/main_page_notifier.dart';
import 'package:eitangocho/features/ads/data/tracking_client.dart';
import 'package:eitangocho/features/analytics/data/analytics_client.dart';
import 'package:eitangocho/features/analytics/data/analytics_logger.dart';
import 'package:eitangocho/features/analytics/domain/analytics_log.dart';
import 'package:eitangocho/features/analytics/domain/analytics_values.dart';
import 'package:eitangocho/features/purchase/data/purchase_notifier.dart';
import 'package:eitangocho/features/settings/data/settings_notifier.dart';
import 'package:eitangocho/features/sync/data/sync_notifier.dart';
import 'package:eitangocho/features/word/data/word_list_provider.dart';
import 'package:eitangocho/utils/app_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ユーザープロパティと主画面の screen_view を、元の状態の変化に合わせて送る。
///
/// 値を返さず、生きている間だけ各 Provider を購読する。MainPage が常に
/// listen して起動から終了まで保つ(learnedWordsProvider と同じやり方)。
///
/// ユーザープロパティは、それ以降に送るイベントに付く。値が変わったときだけ
/// 送り、単語の追加のたびに同じ区間を送り直さない。
///
/// 起動直後は既定値のまま、保存値の復元が終わっていない状態がある
/// (同期の有効・購入状態)。その間に送ると直後のイベントに誤った値が付くため、
/// 確定を待ってから送り始める。
final analyticsReporterProvider = Provider<void>((ref) {
  final client = ref.watch(analyticsClientProvider);
  final logger = ref.watch(analyticsLoggerProvider);

  final sent = <String, String?>{};
  void setProperty(String name, String? value) {
    if (sent.containsKey(name) && sent[name] == value) return;
    sent[name] = value;
    unawaited(client.setUserProperty(name, value));
  }

  // ios / macos(Android 版を出せば android)。分岐ではなく名前を取るだけなので
  // AppPlatform を通さない。
  setProperty('app_platform', defaultTargetPlatform.name.toLowerCase());

  ref
    ..listen(mainPageProvider.select((s) => s.view), (_, view) {
      logger.logScreenView(screenName(view));
    }, fireImmediately: true)
    ..listen(settingsProvider, (_, next) {
      final settings = next.value;
      if (settings == null) return;
      setProperty(
        'translation_language',
        settings.translationLanguage.storageCode,
      );
      setProperty('quiz_direction', quizDirectionValue(settings.quizDirection));
      setProperty('show_ipa', boolValue(value: settings.showIpa));
      setProperty('word_sort_order', snakeCase(settings.wordSortOrder.name));
      if (AppPlatform.isIOS) {
        setProperty('appearance', settings.appearance.name);
        setProperty('card_layout', snakeCase(settings.cardLayout.name));
      }
      if (AppPlatform.isMacOS) {
        setProperty('ui_scale', settings.uiScale.toStringAsFixed(1));
      }
    }, fireImmediately: true)
    ..listen(wordListProvider, (_, next) {
      final words = next.value;
      if (words == null) return;
      setProperty('word_count_bucket', wordCountBucket(words.length));
    }, fireImmediately: true);

  // 同期の有効 / 無効は保存値の復元(SyncNotifier.initialized)までは既定の無効。
  var syncRestored = false;
  ref.listen(syncProvider.select((s) => s.enabled), (_, enabled) {
    if (syncRestored) {
      setProperty('sync_enabled', boolValue(value: enabled));
    }
  });
  unawaited(
    ref.read(syncProvider.notifier).initialized.then((_) {
      if (!ref.mounted) return;
      syncRestored = true;
      setProperty(
        'sync_enabled',
        boolValue(value: ref.read(syncProvider).enabled),
      );
    }),
  );

  if (!AppPlatform.isIOS) return;

  // 購入状態は RevenueCat から届くまで未購入に見える(proUnlockedKnown)。
  var proKnown = false;
  ref.listen(purchaseProvider.select((s) => s.proUnlocked), (_, unlocked) {
    if (proKnown) setProperty('is_pro', boolValue(value: unlocked));
  });
  unawaited(
    ref.read(purchaseProvider.notifier).proUnlockedKnown.then((_) {
      if (!ref.mounted) return;
      proKnown = true;
      setProperty(
        'is_pro',
        boolValue(value: ref.read(purchaseProvider).proUnlocked),
      );
    }),
  );

  // トラッキング許可は ATT のダイアログか設定アプリでしか変わらず、どちらも
  // アプリがアクティブに戻る(resumed)を挟む。起動時と復帰のたびに読む。
  // 状態を読むだけで、ダイアログは出さない(出すのは TrackingAuthorizer)。
  final tracking = ref.watch(trackingClientProvider);
  Future<void> readTrackingStatus() async {
    try {
      final status = await tracking.statusName();
      if (ref.mounted) setProperty('att_status', status);
    } on Object catch (error) {
      analyticsLog('トラッキング許可の状態を読めません: $error');
    }
  }

  unawaited(readTrackingStatus());
  final lifecycle = AppLifecycleListener(
    onResume: () => unawaited(readTrackingStatus()),
  );
  ref.onDispose(lifecycle.dispose);
});
