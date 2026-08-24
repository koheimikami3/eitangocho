import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tracking_client.g.dart';

/// ATT(トラッキング許可)SDK の呼び出しを閉じ込める抽象。
///
/// SDK の型が [TrackingAuthorizer] より上に漏れないようにする
/// (`ReviewClient` と同じ方針)。テストではフェイクに差し替える。
///
/// 応答の中身(許可 / 拒否)は呼び出し側では使わないため、どちらのメソッドも
/// 「確定したか」= `notDetermined` 以外になったか、だけを返す。拒否されても
/// 非パーソナライズ広告は出せるので、広告を出すかどうかの判断には効かない。
abstract interface class TrackingClient {
  /// 許可の状態が確定しているか。true ならダイアログを出す必要はない。
  ///
  /// ユーザーが答えた場合だけでなく、OS 設定でトラッキング要求そのものを
  /// 禁止している端末(`restricted`)や iOS 以外でも true になる。
  Future<bool> isSettled();

  /// ATT のダイアログを出す。確定したかを返す。
  ///
  /// **false が返るのは「ダイアログが出せなかった」とき**。アプリが
  /// アクティブでない間に呼ぶと、iOS 15 以降はダイアログを出さずに
  /// `notDetermined` のまま返る。
  Future<bool> request();
}

/// app_tracking_transparency による実装。
class AppTrackingTransparencyClient implements TrackingClient {
  const AppTrackingTransparencyClient();

  @override
  Future<bool> isSettled() async =>
      await AppTrackingTransparency.trackingAuthorizationStatus !=
      TrackingStatus.notDetermined;

  @override
  Future<bool> request() async =>
      await AppTrackingTransparency.requestTrackingAuthorization() !=
      TrackingStatus.notDetermined;
}

/// ATT の実装。テストではフェイクに差し替える。
@Riverpod(keepAlive: true)
TrackingClient trackingClient(Ref ref) => const AppTrackingTransparencyClient();
