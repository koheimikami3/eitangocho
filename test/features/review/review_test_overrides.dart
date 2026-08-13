import 'package:eitangocho/features/review/data/review_client.dart';

/// レビュー依頼を無効にする Provider の差し替え。
///
/// 広告の [adsDisabled] と同じ理由で置く。クイズを最後まで進めるテストは
/// 完了時にレビュー依頼の判定を通るため、そのままだと実行機に無いプラグインを
/// 叩きに行く。レビューそのものを検証するテスト以外はこれを overrides に足すこと。
final reviewDisabled = reviewClientProvider.overrideWithValue(
  const _DisabledReviewClient(),
);

/// 「レビュー依頼を出せない環境」を表すだけのクライアント。
/// `isAvailable` が false のとき依頼は呼ばれない、という約束を明示する。
class _DisabledReviewClient implements ReviewClient {
  const _DisabledReviewClient();

  @override
  bool get canOpenStoreListing => false;

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<void> requestReview() => throw UnsupportedError('レビュー依頼は無効');

  @override
  Future<void> openStoreListing() => throw UnsupportedError('レビュー依頼は無効');
}
