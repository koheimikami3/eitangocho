import 'package:eitangocho/features/sync/domain/cloud_file_store.dart';
import 'package:flutter/services.dart';

/// iCloud Drive のアプリコンテナに置いた同期ファイルを読み書きする実装。
///
/// 実処理はネイティブ側(shared/IcloudFileStorePlugin.swift)。ファイル名と
/// コンテナの解決はネイティブが持ち、Dart はチャンネル越しに 3 操作を呼ぶだけ。
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

  /// PlatformException を UI に出せる例外へ翻訳する。
  /// ネイティブ側が日本語メッセージを載せているので、それをそのまま使う。
  Future<T> _invoke<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on PlatformException catch (e) {
      throw CloudUnavailableException(e.message ?? 'iCloud との通信に失敗しました。');
    } on MissingPluginException {
      // iCloud 未対応のプラットフォームで呼ばれた場合。
      throw const CloudUnavailableException('このプラットフォームでは iCloud 同期を利用できません。');
    }
  }
}
