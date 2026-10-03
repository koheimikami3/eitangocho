import 'package:eitangocho/db/daos/word_dao.dart';
import 'package:eitangocho/features/review/data/review_client.dart';
import 'package:eitangocho/features/review/domain/review_config.dart';
import 'package:eitangocho/features/review/domain/review_log.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// レビュー依頼を「いつ出すか」を決める。
///
/// 出すのはクイズを最後まで終えた直後([onQuizCompleted])と、登録単語数が
/// 節目に達した保存直後([onWordRegistered])だけ。条件は [ReviewConfig] に
/// まとめてある。
///
/// **レビューの失敗でアプリを止めない**(辞書・広告と同じ方針)。判定も呼び出しも
/// 例外を握ってログだけ出す。レビューが出ないだけで単語帳としては使えるため。
class ReviewPrompter {
  /// [promptDelay] は既定値が本番値で、テストからだけ縮める。
  ReviewPrompter({
    required this.client,
    required this.wordDao,
    this.promptDelay = ReviewConfig.promptDelay,
  });

  static const _keyQuizCompletedCount = 'reviewQuizCompletedCount';
  static const _keyLastRequestedAt = 'reviewLastRequestedAt';

  final ReviewClient client;
  final WordDao wordDao;

  /// 契機の画面遷移から依頼を出すまでの待ち時間。
  final Duration promptDelay;

  /// 遅延生成にするのは、`SharedPreferencesAsync()` の生成自体がプラグイン
  /// 未登録の環境で投げるため。Provider の生成時に投げると、レビューとは無関係な
  /// クイズの回答処理まで巻き込んで落ちる(失敗は下の try で握って捨てる)。
  late final _prefs = SharedPreferencesAsync();

  /// クイズを最後まで終えたときに呼ぶ。条件を満たしたときだけ依頼を出す。
  ///
  /// [okCount] は「覚えている」の数、[total] はそのセッションの出題数。
  Future<void> onQuizCompleted({
    required int okCount,
    required int total,
  }) async {
    try {
      // 完了回数は「達成の総量」を表す指標として使うため、成績や他の条件を
      // 満たさない回も含めて数える。
      final completions = await _incrementQuizCompletions();

      if (!await _shouldRequest(
        okCount: okCount,
        total: total,
        completions: completions,
      )) {
        return;
      }

      await _request('累計クイズ完了 $completions 回');
    } on Object catch (error) {
      reviewLog('レビュー依頼に失敗しました: $error');
    }
  }

  /// 単語登録の保存直後に呼ぶ。登録単語数がちょうど節目
  /// ([ReviewConfig.wordCountMilestones])になったときだけ依頼を出す。
  ///
  /// 「ちょうど」で見るので、節目を一度越えた後は削除して登録し直さない限り
  /// 再び当たらない(当たっても [ReviewConfig.requestInterval] が止める)。
  Future<void> onWordRegistered() async {
    try {
      final wordCount = await wordDao.countWords();
      if (!ReviewConfig.wordCountMilestones.contains(wordCount)) return;
      if (await _isWithinInterval()) return;

      await _request('登録単語 $wordCount 語');
    } on Object catch (error) {
      reviewLog('レビュー依頼に失敗しました: $error');
    }
  }

  /// 設定の常設リンクから App Store のレビュー画面を開く。
  ///
  /// **App Store ID が未設定なら何もしない。** リンク行はデザインどおり常に
  /// 出すため(出し分けをやめた)、開けない状態で SDK を呼ばないようにここで止める。
  Future<void> openStoreListing() async {
    if (!client.canOpenStoreListing) {
      reviewLog('App Store ID が未設定のため開けません');
      return;
    }
    try {
      await client.openStoreListing();
    } on Object catch (error) {
      reviewLog('App Store を開けませんでした: $error');
    }
  }

  /// 累計クイズ完了回数を 1 増やし、増やした後の値を返す。
  Future<int> _incrementQuizCompletions() async {
    final completions = (await _prefs.getInt(_keyQuizCompletedCount) ?? 0) + 1;
    await _prefs.setInt(_keyQuizCompletedCount, completions);
    return completions;
  }

  /// [ReviewConfig] の条件をすべて満たすか。落ちた条件はログに残す。
  Future<bool> _shouldRequest({
    required int okCount,
    required int total,
    required int completions,
  }) async {
    if (total < ReviewConfig.minQuestions) {
      reviewLog('出題数が少ないため見送ります($total 語)');
      return false;
    }
    if (okCount / total < ReviewConfig.minKnewRatio) {
      reviewLog('成績が振るわないため見送ります($okCount/$total)');
      return false;
    }
    if (completions < ReviewConfig.minQuizCompletions) {
      reviewLog('クイズ完了が $completions 回目のため見送ります');
      return false;
    }

    final wordCount = await wordDao.countWords();
    if (wordCount < ReviewConfig.minWordCount) {
      reviewLog('登録単語が少ないため見送ります($wordCount 語)');
      return false;
    }

    return !await _isWithinInterval();
  }

  /// 前回の依頼から [ReviewConfig.requestInterval] が経っていないか。
  /// 経っていなければログを残す。
  Future<bool> _isWithinInterval() async {
    final lastMillis = await _prefs.getInt(_keyLastRequestedAt);
    if (lastMillis == null) return false;
    final elapsed = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(lastMillis),
    );
    if (elapsed < ReviewConfig.requestInterval) {
      reviewLog('前回の依頼から ${elapsed.inDays} 日しか経っていないため見送ります');
      return true;
    }
    return false;
  }

  /// 待ち時間を置いてから依頼を出し、依頼した日時を記録する。
  /// [reason] はログに出す契機の説明。例外は呼び出し側で握る。
  Future<void> _request(String reason) async {
    // 契機の画面遷移とアニメーションが落ち着いてからシートを重ねる。
    await Future<void>.delayed(promptDelay);

    if (!await client.isAvailable()) {
      reviewLog('この端末ではレビュー依頼を出せません');
      return;
    }

    await client.requestReview();
    // **表示されたかは OS が教えてくれない**ため、呼べた時点で「依頼した」と
    // 記録する(クォータで出なかった回も 1 回と数える)。ここを表示の確認まで
    // 待つ手段は無い。
    await _prefs.setInt(
      _keyLastRequestedAt,
      DateTime.now().millisecondsSinceEpoch,
    );
    reviewLog('レビュー依頼を出しました($reason)');
  }
}

/// riverpod_generator は drift 生成型を扱う @riverpod を InvalidTypeException で
/// 落とす既知バグがあるため、この Provider は手書きにする
/// (syncServiceProvider と同じ方針)。待ち時間をテストから縮められる利点もある。
final reviewPrompterProvider = Provider<ReviewPrompter>(
  (ref) => ReviewPrompter(
    client: ref.watch(reviewClientProvider),
    wordDao: ref.watch(databaseProvider).wordDao,
  ),
);
