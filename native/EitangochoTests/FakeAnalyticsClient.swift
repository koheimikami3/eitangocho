@testable import Eitangocho

/// 送った内容を記録するだけの AnalyticsClient(Flutter 版の FakeAnalyticsClient)。
///
/// 送る経路とパラメータの組み立てだけをここで確かめる。
final class FakeAnalyticsClient: AnalyticsClient {
  /// 送ったイベント(screen_view を含む)を送った順に持つ。
  private(set) var events: [(name: String, parameters: [String: AnyHashable])] = []

  /// 最後に設定したユーザープロパティ。
  private(set) var userProperties: [String: String?] = [:]

  /// ユーザープロパティを設定した回数(値が変わったときだけ送るかの確認用)。
  private(set) var userPropertyCalls = 0

  /// `name` のイベントのパラメータを送った順に返す。
  func eventsNamed(_ name: String) -> [[String: AnyHashable]] {
    events.filter { $0.name == name }.map(\.parameters)
  }

  func logEvent(_ name: String, parameters: [String: AnyHashable]) {
    events.append((name, parameters))
  }

  func logScreenView(_ screenName: String) {
    events.append(("screen_view", ["screen_name": screenName]))
  }

  func setUserProperty(_ name: String, value: String?) {
    userPropertyCalls += 1
    userProperties[name] = value
  }
}
