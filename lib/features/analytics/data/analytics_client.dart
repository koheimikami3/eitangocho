import 'package:eitangocho/features/analytics/domain/analytics_log.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_client.g.dart';

/// 計測 SDK の呼び出しを閉じ込める抽象。
///
/// SDK の型が `AnalyticsLogger` より上に漏れないようにする。テストでは
/// フェイクに差し替える(テストの実行機にはプラグインの実体が無いため)。
///
/// **計測の失敗でアプリを止めない**(広告・課金・レビューと同じ方針)。
/// 実装は例外を握って捨てる。
abstract interface class AnalyticsClient {
  Future<void> logEvent(String name, [Map<String, Object>? parameters]);

  Future<void> logScreenView(String screenName);

  /// [value] が null ならそのプロパティを消す。
  Future<void> setUserProperty(String name, String? value);
}

/// Firebase Analytics による実装。
///
/// [ready] は Firebase の初期化結果(initializeAnalytics)。起動を待たせない
/// よう初期化と並行して生成されるため、送る前に毎回待つ。false(debug
/// ビルド・初期化失敗)なら送らず、debug では送るはずだった内容をログに出す。
class FirebaseAnalyticsClient implements AnalyticsClient {
  const FirebaseAnalyticsClient({required this.ready});

  final Future<bool> ready;

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) =>
      _send(
        '$name ${parameters ?? const {}}',
        (analytics) => analytics.logEvent(name: name, parameters: parameters),
      );

  @override
  Future<void> logScreenView(String screenName) => _send(
    'screen_view {screen_name: $screenName}',
    (analytics) => analytics.logScreenView(screenName: screenName),
  );

  @override
  Future<void> setUserProperty(String name, String? value) => _send(
    'user_property $name=$value',
    (analytics) => analytics.setUserProperty(name: name, value: value),
  );

  Future<void> _send(
    String description,
    Future<void> Function(FirebaseAnalytics analytics) send,
  ) async {
    analyticsLog(description);
    try {
      if (!await ready) return;
      await send(FirebaseAnalytics.instance);
    } on Object catch (error) {
      // 送れなくても単語帳としては使える。release でも原因を追えるよう
      // debugPrint で残す(analytics_initializer と同じ)。
      debugPrint('[analytics] 送信に失敗: $description: $error');
    }
  }
}

/// 何も送らない実装。Provider の既定値で、main.dart だけが
/// [FirebaseAnalyticsClient] に差し替える(テストは何もしなくても送らない)。
class NoopAnalyticsClient implements AnalyticsClient {
  const NoopAnalyticsClient();

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {}

  @override
  Future<void> logScreenView(String screenName) async {}

  @override
  Future<void> setUserProperty(String name, String? value) async {}
}

/// 計測の実装。main.dart で Firebase の実装に差し替える。
@Riverpod(keepAlive: true)
AnalyticsClient analyticsClient(Ref ref) => const NoopAnalyticsClient();
