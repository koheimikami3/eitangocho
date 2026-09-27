/// クラウド上の 1 ファイルを読み書きする抽象。
///
/// 同期は「アプリのクラウドコンテナに置いた JSON スナップショット 1 個」で
/// 成立するため、必要な操作はこの 3 つだけに絞ってある。
/// 実装は iCloud Drive([IcloudFileStore])。テストではインメモリ実装を注入する
/// (WordInfoProvider と同じ「抽象の裏に実装を隠す」方針)。
abstract interface class CloudFileStore {
  /// ファイルの内容。まだ存在しなければ null。
  Future<String?> read();

  /// ファイルを書き込む(存在しなければ作成)。
  Future<void> write(String contents);

  /// ファイルの最終更新日時。存在しなければ null。
  ///
  /// 書き込み直前に読み取り時から変化していないかを確かめ、他端末の書き込みを
  /// 踏み潰さないために使う([SyncService] 参照)。
  Future<DateTime?> lastModified();
}

/// クラウドが使えないときの失敗。UI にそのまま出せる日本語メッセージを持つ。
class CloudUnavailableException implements Exception {
  const CloudUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 端末のコピーがクラウドの最新版にならず、同期を見送ったときの失敗。
///
/// 古いコピーを読んで書き戻すと、他端末の新しい版を踏み潰して競合版に追いやるため、
/// 最新化を待ちきれなかったときは読み書きせずにこれを投げる。
/// 一時的な状態なので、[SyncNotifier] は少し待って再試行する。
class CloudNotReadyException extends CloudUnavailableException {
  const CloudNotReadyException(super.message);
}
