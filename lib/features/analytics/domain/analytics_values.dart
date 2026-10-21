import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/features/settings/domain/quiz_direction.dart';
import 'package:eitangocho/features/sync/domain/cloud_file_store.dart';

/// 計測に送る値の変換。GA4 のレポートで読みやすく、後から変えないで済む
/// 文字列にそろえる(イベント名・値を変えると過去のデータとつながらない)。

/// 単語の自動入力の結果(autofill_result の result)。
enum AutofillResult { success, notFound, fetchFailed }

/// クイズを始めた契機(quiz_started の trigger)。
enum QuizTrigger {
  /// タブバー・サイドバーからクイズを開いた。
  tab,

  /// 結果画面の「続ける」。
  continued,
}

/// Pro 購入の段階(pro_purchase の stage)。
enum ProPurchaseStage { tapped, success, cancelled, failed }

/// レビュー依頼を出した契機(review_requested の trigger)。
enum ReviewTrigger {
  /// クイズを最後まで終えた直後。
  quiz,

  /// 登録単語数が節目(50 / 100 語)に達した直後。
  wordMilestone,
}

/// enum の名前(lowerCamelCase)を snake_case にする。
String snakeCase(String camel) =>
    camel.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');

/// 画面名(screen_view の screen_name、各イベントの screen)。
String screenName(MainView view) => snakeCase(view.name);

/// [QuizTrigger] の値。`continue` は Dart の予約語なので enum 名とずらしている。
String quizTriggerValue(QuizTrigger trigger) => switch (trigger) {
  QuizTrigger.tab => 'tab',
  QuizTrigger.continued => 'continue',
};

/// 出題方向。enum 名の `ja` は多言語化前の名残で、訳の言語は日本語に限らない
/// ため、英語から / 英語への向きで表す。
String quizDirectionValue(QuizDirection direction) => switch (direction) {
  QuizDirection.enToJa => 'from_english',
  QuizDirection.jaToEn => 'to_english',
};

/// 同期の失敗理由。`noICloud` を機械的に snake_case にすると `no_i_cloud` に
/// なるため、個別に書く。
String syncFailureValue(CloudFailureReason reason) => switch (reason) {
  CloudFailureReason.noICloud => 'no_icloud',
  CloudFailureReason.notCurrent => 'not_current',
  CloudFailureReason.unsupportedPlatform => 'unsupported_platform',
  CloudFailureReason.failed => 'failed',
};

/// 登録単語数の区間(word_count_bucket)。
///
/// 値の頭の番号は、GA4 が値を文字列の辞書順に並べるため(番号が無いと
/// 「1-9」「10-49」「100-299」「2000+」「50-99」の順になる)。
String wordCountBucket(int count) {
  if (count <= 0) return '0_none';
  if (count < 10) return '1_1-9';
  if (count < 50) return '2_10-49';
  if (count < 100) return '3_50-99';
  if (count < 300) return '4_100-299';
  if (count < 500) return '5_300-499';
  if (count < 1000) return '6_500-999';
  if (count < 2000) return '7_1000-1999';
  return '8_2000+';
}

/// クイズの出題のうち、前回答えてから最も日が空いていた単語の日数の区間
/// (quiz_started の review_gap_bucket)。
///
/// 出題の選び方(selectQuizQuestions)が学習済みの単語を等間隔で一巡させられて
/// いるかを見るためのもの。まだ一度も答えていない単語は日数が無いので除き、
/// 全部がそうなら `0_none`。
String reviewGapBucket(Iterable<DateTime?> lastReviewedAts, DateTime now) {
  final gaps = lastReviewedAts.nonNulls.map((at) => now.difference(at).inDays);
  if (gaps.isEmpty) return '0_none';
  final days = gaps.reduce((a, b) => a > b ? a : b);
  if (days < 7) return '1_0-6';
  if (days < 30) return '2_7-29';
  if (days < 90) return '3_30-89';
  return '4_90+';
}

/// GA4 のパラメータとユーザープロパティは bool を受けないため文字列にする。
String boolValue({required bool value}) => value ? 'true' : 'false';
