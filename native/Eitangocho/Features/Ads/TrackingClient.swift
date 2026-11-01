import AppTrackingTransparency
import Foundation

/// ATT(トラッキング許可)の呼び出しを閉じ込める抽象(Flutter 版の TrackingClient)。
///
/// OS の型が `TrackingAuthorizer` より上に漏れないようにする(`ReviewClient` と同じ方針)。
/// テストではフェイクに差し替える。
///
/// 応答の中身(許可 / 拒否)は広告の判断には使わないため、`isSettled` / `request` は「確定したか」=
/// `notDetermined` 以外になったか、だけを返す。拒否されても非パーソナライズ広告は出せるので、
/// 広告を出すかどうかの判断には効かない。中身は計測(att_status)のためだけに `statusName` で読む。
protocol TrackingClient {
  /// 許可の状態が確定しているか。true ならダイアログを出す必要はない。
  ///
  /// ユーザーが答えた場合だけでなく、OS 設定でトラッキング要求そのものを禁止している端末
  /// (`restricted`)でも true になる。
  func isSettled() async -> Bool

  /// ATT のダイアログを出す。確定したかを返す。
  ///
  /// **false が返るのは「ダイアログが出せなかった」とき**。アプリがアクティブでない間に呼ぶと、
  /// iOS 15 以降はダイアログを出さずに `notDetermined` のまま返る。
  func request() async -> Bool

  /// 今の許可の状態の名前(`authorized` / `denied` / `restricted` / `not_determined`)。
  /// ダイアログは出さない。名前は Flutter 版と同じ(att_status の値)。
  func statusName() -> String
}

/// AppTrackingTransparency による実装。
struct SystemTrackingClient: TrackingClient {
  func isSettled() async -> Bool {
    ATTrackingManager.trackingAuthorizationStatus != .notDetermined
  }

  func request() async -> Bool {
    await ATTrackingManager.requestTrackingAuthorization() != .notDetermined
  }

  func statusName() -> String {
    switch ATTrackingManager.trackingAuthorizationStatus {
    case .authorized: "authorized"
    case .denied: "denied"
    case .restricted: "restricted"
    case .notDetermined: "not_determined"
    // Flutter 版の app_tracking_transparency は知らない値を not_supported にしていた(iOS 14 未満の値)。
    @unknown default: "not_supported"
    }
  }
}
