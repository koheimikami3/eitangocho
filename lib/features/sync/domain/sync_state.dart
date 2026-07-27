import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_state.freezed.dart';

/// iCloud 同期の状態。設定画面の表示にそのまま使う。
@freezed
abstract class SyncState with _$SyncState {
  const factory SyncState({
    /// 同期を有効にしているか。既定は無効(ユーザーが明示的に入にする)。
    @Default(false) bool enabled,

    /// 同期の実行中か。
    @Default(false) bool syncing,

    /// 最後に成功した同期の日時。まだ一度も成功していなければ null。
    DateTime? lastSyncedAt,

    /// 直近の同期の失敗メッセージ。成功したら消す。
    String? errorMessage,
  }) = _SyncState;
}
