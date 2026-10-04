import 'package:eitangocho/features/sync/domain/cloud_file_store.dart';
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

    /// 直近の同期の失敗。成功したら消す。
    SyncFailure? failure,
  }) = _SyncState;
}

/// 同期の失敗。文言は表示側(syncFailureText)が言語に合わせて組み立てる。
@freezed
abstract class SyncFailure with _$SyncFailure {
  const factory SyncFailure({
    required CloudFailureReason reason,

    /// 理由だけでは伝わらない補足(OS が返した説明・想定外の例外の内容)。
    String? detail,
  }) = _SyncFailure;
}
