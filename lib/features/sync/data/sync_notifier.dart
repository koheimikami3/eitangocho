import 'package:eitangocho/features/sync/data/sync_service.dart';
import 'package:eitangocho/features/sync/domain/cloud_file_store.dart';
import 'package:eitangocho/features/sync/domain/sync_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// iCloud 同期の有効/無効・実行状態を持つ。
///
/// 設定と同じく shared_preferences に永続化する。同期そのものは
/// [SyncService] が行い、ここは「いつ走らせるか」と結果の保持だけを担う。
class SyncNotifier extends Notifier<SyncState> {
  static const _keyEnabled = 'syncEnabled';
  static const _keyLastSyncedAt = 'syncLastSyncedAt';

  final _prefs = SharedPreferencesAsync();

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
      if (state.enabled) syncNow();
    });
    return const SyncState();
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
    state = state.copyWith(enabled: enabled, errorMessage: null);
    if (enabled) await syncNow();
  }

  /// 同期を 1 回実行する。無効時・実行中は何もしない。
  /// 同期は数秒かかることがあり、その間に画面や container が破棄されうる。
  /// await のたびに ref.mounted を確かめてから state を書く。
  Future<void> syncNow() async {
    await _restored;
    if (!ref.mounted) return;
    if (!state.enabled || state.syncing) return;
    state = state.copyWith(syncing: true, errorMessage: null);
    try {
      await ref.read(syncServiceProvider).sync();
      final now = DateTime.now();
      await _prefs.setInt(_keyLastSyncedAt, now.millisecondsSinceEpoch);
      if (!ref.mounted) return;
      state = state.copyWith(syncing: false, lastSyncedAt: now);
    } on CloudUnavailableException catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(syncing: false, errorMessage: e.message);
    } on Object catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        syncing: false,
        errorMessage: '同期に失敗しました: $e',
      );
    }
  }
}

/// riverpod_generator は drift 生成型に依存する Provider を
/// InvalidTypeException で落とすため、手書きにする
/// (syncServiceProvider を読むためここも同様)。
final syncProvider = NotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);
