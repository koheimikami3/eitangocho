import 'package:eitangocho/features/sync/domain/cloud_file_store.dart';
import 'package:flutter/services.dart';

/// iCloud Drive のアプリコンテナに置いた同期ファイルを読み書きする実装。
///
/// 実処理はネイティブ側(shared/IcloudFileStorePlugin.swift)。ファイル名と
/// コンテナの解決はネイティブが持ち、Dart はチャンネル越しに操作を呼ぶだけ。
class IcloudFileStore implements CloudFileStore {
  const IcloudFileStore({this.channel = _defaultChannel});

  static const _defaultChannel = MethodChannel('eitangocho/icloud');

  /// テストで差し替えるために公開している。通常は既定値のままでよい。
  final MethodChannel channel;

  @override
  Future<String?> read() => _invoke(() => channel.invokeMethod<String>('read'));

  @override
  Future<void> write(String contents) => _invoke(
    () => channel.invokeMethod<void>('write', {'contents': contents}),
  );

  @override
  Future<DateTime?> lastModified() async {
    // ネイティブは epoch ミリ秒で返す(DateTime を直接運べないため)。
    final millis = await _invoke(
      () => channel.invokeMethod<int>('lastModified'),
    );
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  @override
  Future<List<CloudConflict>> readConflicts() async {
    final items = await _invoke(
      () => channel.invokeListMethod<Map<Object?, Object?>>('readConflicts'),
    );
    return [
      for (final item in items ?? const <Map<Object?, Object?>>[])
        CloudConflict(
          id: item['id']! as String,
          contents: item['contents']! as String,
          // ネイティブは epoch ミリ秒で返す(lastModified と同じ)。
          modifiedAt: switch (item['modifiedAt']) {
            final int millis => DateTime.fromMillisecondsSinceEpoch(millis),
            _ => null,
          },
        ),
    ];
  }

  @override
  Future<void> resolveConflicts(List<String> ids) => _invoke(
    () => channel.invokeMethod<void>('resolveConflicts', {'ids': ids}),
  );

  /// PlatformException を理由付きの例外へ翻訳する。
  ///
  /// ネイティブ側のメッセージは日本語固定なので、表示には使わずコードで
  /// 理由を決める(文言は表示側が言語に合わせて出す)。コードはネイティブ側
  /// (IcloudFileStorePlugin.swift)と合わせる。読み書きの失敗は OS が
  /// 端末の言語で返す説明(localizedDescription)なので、補足として残す。
  Future<T> _invoke<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on PlatformException catch (e) {
      throw switch (e.code) {
        'no-icloud' => const CloudUnavailableException(
          CloudFailureReason.noICloud,
        ),
        'not-current' => const CloudNotReadyException(),
        _ => CloudUnavailableException(CloudFailureReason.failed, e.message),
      };
    } on MissingPluginException {
      // iCloud 未対応のプラットフォームで呼ばれた場合。
      throw const CloudUnavailableException(
        CloudFailureReason.unsupportedPlatform,
      );
    }
  }
}
