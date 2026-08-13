import 'package:eitangocho/features/review/data/review_client.dart';

/// プラグインに触れない [ReviewClient]。
///
/// テストの実行機は macOS で、レビュー依頼のプラグインは実体があっても
/// ダイアログを出さない(ストア配布版でしか出ない)。判定の経路を確かめるため、
/// 呼ばれた回数だけを数える。
class FakeReviewClient implements ReviewClient {
  FakeReviewClient({this.available = true, this.canOpenStoreListing = true});

  /// レビュー依頼を出せる端末か。
  bool available;

  /// App Store ID が設定されているか(設定のリンク行の出し分け)。
  @override
  final bool canOpenStoreListing;

  /// 投げさせたい例外。
  Object? requestError;
  Object? openStoreListingError;

  var requestCount = 0;
  var openStoreListingCount = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> requestReview() async {
    requestCount++;
    if (requestError != null) throw requestError!;
  }

  @override
  Future<void> openStoreListing() async {
    openStoreListingCount++;
    if (openStoreListingError != null) throw openStoreListingError!;
  }
}
