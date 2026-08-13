import 'package:eitangocho/features/review/domain/review_config.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review_client.g.dart';

/// レビュー依頼 SDK の呼び出しを閉じ込める抽象。
///
/// SDK の型が [ReviewPrompter] より上に漏れないようにする。テストでは
/// フェイクに差し替える(テストの実行機にはプラグインの実体が無いため)。
abstract interface class ReviewClient {
  /// 設定に App Store のレビューリンクを出せるか。
  /// false なら [openStoreListing] は呼ばれない(リンク行ごと出さない)。
  bool get canOpenStoreListing;

  /// レビュー依頼を出せる環境か。false なら [requestReview] は呼ばない。
  Future<bool> isAvailable();

  /// OS 標準のレビュー依頼を出す。
  ///
  /// **実際に表示されたかは OS が教えてくれない**(クォータ超過・ユーザーが
  /// 設定で無効化していれば黙って何も起きない)。呼べたかどうかまでしか
  /// 分からない前提で扱うこと。
  Future<void> requestReview();

  /// App Store のレビュー画面を開く(設定の常設リンク)。
  Future<void> openStoreListing();
}

/// in_app_review による実装。
class InAppReviewClient implements ReviewClient {
  const InAppReviewClient();

  @override
  bool get canOpenStoreListing => ReviewConfig.canOpenStoreListing;

  @override
  Future<bool> isAvailable() => InAppReview.instance.isAvailable();

  @override
  Future<void> requestReview() => InAppReview.instance.requestReview();

  @override
  Future<void> openStoreListing() =>
      InAppReview.instance.openStoreListing(appStoreId: ReviewConfig.appStoreId);
}

/// レビュー依頼の実装。テストではフェイクに差し替える。
@Riverpod(keepAlive: true)
ReviewClient reviewClient(Ref ref) => const InAppReviewClient();
