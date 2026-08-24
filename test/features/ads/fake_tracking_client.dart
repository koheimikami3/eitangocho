import 'package:eitangocho/features/ads/data/tracking_client.dart';

/// SDK に触れない [TrackingClient]。
///
/// テストの実行機は macOS で ATT プラグインの実体が無いため、トラッキング
/// 許可まわりの検証はすべてこれに差し替えて行う([FakePurchasesClient] と
/// 同じ理由)。
class FakeTrackingClient implements TrackingClient {
  FakeTrackingClient({this.settled = false, this.dialogShows = true});

  /// 許可の状態が確定済みか。[request] が成功すると true になる。
  bool settled;

  /// [request] でダイアログが出るか。false は「非アクティブ中に呼んだので
  /// 出ないまま返った」を模す。
  bool dialogShows;

  /// 投げさせたい例外。
  Object? requestError;

  var isSettledCount = 0;
  var requestCount = 0;

  @override
  Future<bool> isSettled() async {
    isSettledCount++;
    return settled;
  }

  @override
  Future<bool> request() async {
    requestCount++;
    if (requestError != null) throw requestError!;
    if (dialogShows) settled = true;
    return settled;
  }
}
