import 'package:eitangocho/features/analytics/data/analytics_client.dart';

/// 送った内容を記録するだけの [AnalyticsClient]。
///
/// 計測のプラグインはテストの実行機に実体が無いため、送る経路と
/// パラメータの組み立てだけをここで確かめる。
class FakeAnalyticsClient implements AnalyticsClient {
  /// 送ったイベント(screen_view を含む)を送った順に持つ。
  final events = <({String name, Map<String, Object> parameters})>[];

  /// 最後に設定したユーザープロパティ。
  final userProperties = <String, String?>{};

  /// ユーザープロパティを設定した回数(値が変わったときだけ送るかの確認用)。
  var userPropertyCalls = 0;

  /// [name] のイベントのパラメータを送った順に返す。
  List<Map<String, Object>> eventsNamed(String name) => [
    for (final e in events)
      if (e.name == name) e.parameters,
  ];

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    events.add((name: name, parameters: parameters ?? const {}));
  }

  @override
  Future<void> logScreenView(String screenName) async {
    events.add((name: 'screen_view', parameters: {'screen_name': screenName}));
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    userPropertyCalls++;
    userProperties[name] = value;
  }
}
