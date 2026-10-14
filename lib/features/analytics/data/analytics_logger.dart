import 'dart:async';

import 'package:eitangocho/app/main_page_state.dart';
import 'package:eitangocho/db/app_database.dart';
import 'package:eitangocho/features/analytics/data/analytics_client.dart';
import 'package:eitangocho/features/analytics/domain/analytics_values.dart';
import 'package:eitangocho/features/settings/domain/author_app.dart';
import 'package:eitangocho/features/sync/domain/cloud_file_store.dart';
import 'package:eitangocho/features/word_registration/domain/registration_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 独自イベントの送信口。イベント名とパラメータの組み立てをここに集約し、
/// 呼び出し側は 1 行で済むようにする。
///
/// 各イベントは「値によってどの判断が変わるか」で絞り込んだもの
/// (docs/design.md「計測」)。**ユーザーが入力した中身(単語・訳・検索語・
/// 例文)は送らない**。送るのは区分と件数だけ。
///
/// 送信は待たない(計測の都合で操作を遅らせない)。失敗は [AnalyticsClient] が握る。
class AnalyticsLogger {
  const AnalyticsLogger(this._client);

  final AnalyticsClient _client;

  /// soon_after_quiz の判定に使う、クイズで答えてからの時間。
  static const soonAfterQuiz = Duration(hours: 24);

  void _log(String name, [Map<String, Object>? parameters]) =>
      unawaited(_client.logEvent(name, parameters));

  void logScreenView(String screen) => unawaited(_client.logScreenView(screen));

  /// 自動入力の結果。[notice] は取得できたとき(success)だけ意味を持つ。
  void logAutofillResult({
    required AutofillResult result,
    required bool isPhrase,
    RegistrationNotice? notice,
  }) => _log('autofill_result', {
    'result': snakeCase(result.name),
    if (result == AutofillResult.success)
      'notice': notice == null ? 'none' : snakeCase(notice.name),
    'is_phrase': boolValue(value: isPhrase),
  });

  /// 単語の登録。自動入力の値を書き換えたかは自動入力のときだけ送る
  /// (手動入力では比べる元が無い)。
  void logWordRegistered({
    required bool autoFilled,
    bool editedMeaning = false,
    bool editedExample = false,
    bool editedIpa = false,
  }) => _log('word_registered', {
    'method': autoFilled ? 'autofill' : 'manual',
    if (autoFilled) ...{
      'edited_meaning': boolValue(value: editedMeaning),
      'edited_example': boolValue(value: editedExample),
      'edited_ipa': boolValue(value: editedIpa),
    },
  });

  /// 「覚えた」の付け外し(ユーザーの操作だけ。クイズの「忘れていた」による
  /// 自動の戻しは送らない)。
  ///
  /// soon_after_quiz は、クイズで答えてから [soonAfterQuiz] 以内の操作か。
  /// 「忘れていた」で学習中に戻された単語をすぐ付け直しているかを見て、
  /// 自動で戻す仕様の要否を判断するためのもの。
  void logWordLearnedToggled(
    Word word, {
    required bool isLearned,
    DateTime? now,
  }) {
    final reviewedAt = word.lastReviewedAt;
    final soon =
        reviewedAt != null &&
        (now ?? DateTime.now()).difference(reviewedAt) < soonAfterQuiz;
    _log('word_learned_toggled', {
      'to': isLearned ? 'learned' : 'learning',
      'soon_after_quiz': boolValue(value: soon),
    });
  }

  void logWordDeleted(Word word) =>
      _log('word_deleted', {'was_learned': boolValue(value: word.isLearned)});

  void logPronunciationOpened(MainView view) =>
      _log('pronunciation_opened', {'screen': screenName(view)});

  void logSearchUsed(MainView view) =>
      _log('search_used', {'screen': screenName(view)});

  void logQuizStarted({
    required QuizTrigger trigger,
    required List<Word> questions,
    DateTime? now,
  }) => _log('quiz_started', {
    'trigger': quizTriggerValue(trigger),
    'review_gap_bucket': reviewGapBucket(
      questions.map((w) => w.lastReviewedAt),
      now ?? DateTime.now(),
    ),
  });

  void logQuizEmptyShown() => _log('quiz_empty_shown');

  void logQuizCompleted({required int okCount, required int forgotCount}) =>
      _log('quiz_completed', {
        'ok_count': okCount,
        'forgot_count': forgotCount,
      });

  void logQuizAbandoned({required int answeredCount}) =>
      _log('quiz_abandoned', {'answered_count': answeredCount});

  /// 同期の失敗。OS が返す説明(SyncFailure.detail)はパスが混ざりうるので送らない。
  void logSyncFailed(CloudFailureReason reason) =>
      _log('sync_failed', {'reason': syncFailureValue(reason)});

  void logDataExported() => _log('data_exported');

  void logDataImported({required bool succeeded}) =>
      _log('data_imported', {'result': succeeded ? 'success' : 'failed'});

  void logAuthorAppTapped(AuthorApp app) =>
      _log('author_app_tapped', {'app': app.name});

  void logStoreListingOpened() => _log('store_listing_opened');

  void logProPurchase(ProPurchaseStage stage) =>
      _log('pro_purchase', {'stage': stage.name});
}

/// riverpod_generator は drift 生成型(Word)を扱う @riverpod を
/// InvalidTypeException で落とすため、手書きにする(reviewPrompterProvider と同じ)。
final analyticsLoggerProvider = Provider<AnalyticsLogger>(
  (ref) => AnalyticsLogger(ref.watch(analyticsClientProvider)),
);
