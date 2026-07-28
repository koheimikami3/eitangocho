import 'package:eitangocho/features/sync/domain/sync_state.dart';

/// 同期状態を 1 行の説明文にする。macOS 版 / iOS 版の設定画面で共通に使う。
String syncStatusText(SyncState state) {
  if (!state.enabled) {
    return 'iCloud を使う端末同士で単語帳を同期します。';
  }
  if (state.syncing) return '同期中...';
  if (state.errorMessage != null) return state.errorMessage!;
  final at = state.lastSyncedAt;
  if (at == null) return 'まだ同期していません。';
  return '最終同期: ${_formatDateTime(at)}';
}

/// 「2026/07/27 21:45」形式。秒までは出さない(1 行の情報量を抑えるため)。
String _formatDateTime(DateTime at) {
  final local = at.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year}/${two(local.month)}/${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}
