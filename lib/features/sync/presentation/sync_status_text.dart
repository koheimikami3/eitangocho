import 'package:eitangocho/features/sync/domain/sync_state.dart';

/// 「今すぐ同期」行の右端に出す同期状態。macOS 版 / iOS 版で共通に使う。
///
/// 同期が有効なときだけ呼ぶ(無効なら行そのものが出ない)。エラーは長く
/// 折り返しが要るため、この文には混ぜず行を分けて赤字で出す。
String syncStatusText(SyncState state) {
  if (state.syncing) return '同期中...';
  final at = state.lastSyncedAt;
  if (at == null) return 'まだ同期していません';
  return '最終同期: ${_formatDateTime(at)}';
}

/// 「2026/07/27 21:45」形式。秒までは出さない(1 行の情報量を抑えるため)。
String _formatDateTime(DateTime at) {
  final local = at.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year}/${two(local.month)}/${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}
