import 'dart:async';

import 'package:drift/drift.dart';
import 'package:eitangocho/features/sync/data/sync_service.dart';
import 'package:eitangocho/features/sync/domain/cloud_file_store.dart';
import 'package:eitangocho/features/sync/domain/sync_state.dart';
import 'package:eitangocho/providers/database_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// iCloud 同期の有効/無効・実行状態を持つ。
///
/// 設定と同じく shared_preferences に永続化する。同期そのものは
/// [SyncService] が行い、ここは「いつ走らせるか」と結果の保持だけを担う。
///
/// 走らせる契機は 4 つ: 起動時 / フォアグラウンド復帰時 / ローカル変更後
/// (デバウンス)/ 設定画面の「今すぐ同期」。最新のデータを取得できずに見送ったときは、
/// 加えて 1 回だけ再試行する。
class SyncNotifier extends Notifier<SyncState> {
  /// [debounce] / [resumeMinInterval] / [notReadyRetryDelay] は既定値が本番値で、
  /// テストからだけ縮める。
  SyncNotifier({
    this.debounce = const Duration(seconds: 5),
    this.resumeMinInterval = const Duration(seconds: 60),
    this.notReadyRetryDelay = const Duration(seconds: 30),
  });

  static const _keyEnabled = 'syncEnabled';
  static const _keyLastSyncedAt = 'syncLastSyncedAt';

  /// ローカル変更を検知してから同期するまでの待ち時間。
  /// 連続した編集やクイズの連続回答を 1 回の書き戻しに畳むために置く。
  final Duration debounce;

  /// フォアグラウンド復帰で同期する最短間隔。
  /// macOS はウィンドウを行き来する度に resumed が来るため、これが無いと
  /// フォーカスを移すだけで iCloud への書き戻しが走ってしまう。
  final Duration resumeMinInterval;

  /// 最新のデータを取得できずに同期を見送ってから、再試行するまでの待ち時間。
  /// 見送ったままだと、この端末の変更が次の契機(復帰など)まで iCloud に上がらない。
  final Duration notReadyRetryDelay;

  final _prefs = SharedPreferencesAsync();

  Timer? _debounceTimer;
  Timer? _retryTimer;

  /// 再試行として実行中の同期か。再試行も見送りになったとき、重ねて予約しないために持つ。
  bool _retrying = false;
  StreamSubscription<Set<TableUpdate>>? _localChanges;

  late final Future<void> _restored;

  /// 保存値の復元が終わったことを表す Future。
  ///
  /// 復元は非同期なので、状態を変える操作はこれを待ってから行う。待たないと、
  /// 復元完了前のユーザー操作が、後から流れ込む保存値に上書きされてしまう。
  Future<void> get initialized => _restored;

  @override
  SyncState build() {
    // まず既定値で描き始めてから保存値を流し込む(設定と違い、同期状態は
    // 読めていなくても画面が成立するため AsyncValue にはしない)。
    _restored = _restore();
    // 有効だった場合の起動時同期は、復元が終わってから走らせる
    // (syncNow 自身が _restored を待つため、ここで待ってから呼ぶ)。
    _restored.then((_) {
      if (!ref.mounted) return;
      if (!state.enabled) return;
      _watchLocalChanges();
      syncNow();
    });

    // iOS はアプリを終了させずサスペンドするため、ホームに戻して開き直しても
    // 起動時同期は走らない。復帰トリガが無いと他端末の変更を受け取れない。
    final lifecycle = AppLifecycleListener(onResume: _onResume);

    ref.onDispose(() {
      _unwatchLocalChanges();
      lifecycle.dispose();
    });

    return const SyncState();
  }

  /// ローカル変更の監視を始める。
  ///
  /// 検知は DAO の呼び出し元(登録・編集・削除・学習済み切替の 9 箇所)ではなく、
  /// drift の更新通知 1 本にまとめる。呼び出し元に散らすと、単語を変更する導線を
  /// 足すたびに書き漏らすため。
  ///
  /// 同期が有効な間だけ購読する。無効なら DB に触れる必要がないうえ、
  /// 起動直後に DB インスタンスを生成してしまうのを避けられる。
  void _watchLocalChanges() {
    if (_localChanges != null) return;
    final db = ref.read(databaseProvider);
    _localChanges = db
        .tableUpdates(TableUpdateQuery.onAllTables([db.words, db.deletedWords]))
        .listen((_) => _onLocalChange());
  }

  void _unwatchLocalChanges() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _cancelRetry();
    _localChanges?.cancel();
    _localChanges = null;
  }

  /// words / deleted_words が変わったとき。デバウンスして同期を予約する。
  ///
  /// クイズの回答も words の更新なのでここに来る。回答は updatedAt を動かさないが、
  /// 受信側は lastReviewedAt だけを新しい方に揃える(WordExportService.importJson)
  /// ので、出題の一巡を端末間で共有するために同期する。連続回答はデバウンスで
  /// 1 回に畳まれる。
  void _onLocalChange() {
    if (!state.enabled) return;
    // 同期自身の取り込みで再トリガしないよう、実行中の通知は捨てる
    // (取り込んだ内容はその同期が最後に書き戻すので取りこぼしにならない)。
    if (state.syncing) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, syncNow);
  }

  /// 見送った同期の再試行を 1 回だけ予約する。
  ///
  /// 再試行も見送りになったら重ねて予約しない。取得が長引いているときに
  /// 再試行を回し続けないためで、以後は通常の契機に任せる。
  void _scheduleRetry() {
    if (_retrying || _retryTimer != null) return;
    _retryTimer = Timer(notReadyRetryDelay, () async {
      _retryTimer = null;
      _retrying = true;
      try {
        await syncNow();
      } finally {
        _retrying = false;
      }
    });
  }

  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// フォアグラウンドに戻ったとき。前回同期から時間が経っていれば同期する。
  void _onResume() {
    if (!state.enabled || state.syncing) return;
    final lastSyncedAt = state.lastSyncedAt;
    if (lastSyncedAt != null &&
        DateTime.now().difference(lastSyncedAt) < resumeMinInterval) {
      return;
    }
    syncNow();
  }

  Future<void> _restore() async {
    final enabled = await _prefs.getBool(_keyEnabled) ?? false;
    final millis = await _prefs.getInt(_keyLastSyncedAt);
    // 復元の途中で破棄されることがある(起動直後に閉じた場合など)。
    if (!ref.mounted) return;
    state = state.copyWith(
      enabled: enabled,
      lastSyncedAt: millis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(millis),
    );
  }

  /// 同期の有効/無効を切り替える。有効にした直後は 1 回同期する。
  Future<void> setEnabled({required bool enabled}) async {
    await _restored;
    await _prefs.setBool(_keyEnabled, enabled);
    if (!ref.mounted) return;
    state = state.copyWith(enabled: enabled, failure: null);
    if (enabled) {
      _watchLocalChanges();
      await syncNow();
    } else {
      _unwatchLocalChanges();
    }
  }

  /// 同期を 1 回実行する。無効時・実行中は何もしない。
  /// 同期は数秒かかることがあり、その間に画面や container が破棄されうる。
  /// await のたびに ref.mounted を確かめてから state を書く。
  Future<void> syncNow() async {
    await _restored;
    if (!ref.mounted) return;
    if (!state.enabled || state.syncing) return;
    state = state.copyWith(syncing: true, failure: null);
    try {
      await ref.read(syncServiceProvider).sync();
      final now = DateTime.now();
      await _prefs.setInt(_keyLastSyncedAt, now.millisecondsSinceEpoch);
      if (!ref.mounted) return;
      // 他の契機で同期できたので、予約済みの再試行は要らない。
      _cancelRetry();
      state = state.copyWith(syncing: false, lastSyncedAt: now);
    } on CloudNotReadyException catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(syncing: false, failure: _failureOf(e));
      _scheduleRetry();
    } on CloudUnavailableException catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(syncing: false, failure: _failureOf(e));
    } on Object catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        syncing: false,
        failure: SyncFailure(reason: CloudFailureReason.failed, detail: '$e'),
      );
    }
  }

  static SyncFailure _failureOf(CloudUnavailableException e) =>
      SyncFailure(reason: e.reason, detail: e.detail);
}

/// riverpod_generator は drift 生成型に依存する Provider を
/// InvalidTypeException で落とすため、手書きにする
/// (syncServiceProvider を読むためここも同様)。
final syncProvider = NotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);
