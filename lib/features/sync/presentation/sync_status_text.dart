import 'package:eitangocho/features/sync/domain/cloud_file_store.dart';
import 'package:eitangocho/features/sync/domain/sync_state.dart';
import 'package:eitangocho/l10n/app_localizations.dart';

/// 「今すぐ同期」行の右端に出す同期状態。macOS 版 / iOS 版で共通に使う。
///
/// 同期が有効なときだけ呼ぶ(無効なら行そのものが出ない)。エラーは長く
/// 折り返しが要るため、この文には混ぜず行を分けて赤字で出す(syncFailureText)。
String syncStatusText(AppLocalizations l10n, SyncState state) {
  if (state.syncing) return l10n.syncing;
  final at = state.lastSyncedAt;
  if (at == null) return l10n.neverSynced;
  return l10n.lastSynced(_formatDateTime(at));
}

/// 同期の失敗を伝える文。macOS 版 / iOS 版で共通に使う。
String syncFailureText(AppLocalizations l10n, SyncFailure failure) =>
    switch (failure.reason) {
      CloudFailureReason.noICloud => l10n.syncErrorNoICloud,
      CloudFailureReason.notCurrent => l10n.syncErrorNotCurrent,
      CloudFailureReason.unsupportedPlatform => l10n.syncErrorUnsupported,
      CloudFailureReason.failed => l10n.syncErrorFailed(failure.detail ?? ''),
    };

/// 「2026/07/27 21:45」形式。秒までは出さない(1 行の情報量を抑えるため)。
String _formatDateTime(DateTime at) {
  final local = at.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year}/${two(local.month)}/${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}
