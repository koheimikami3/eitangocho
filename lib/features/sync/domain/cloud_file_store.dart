/// クラウド上の 1 ファイルを読み書きする抽象。
///
/// 同期は「アプリのクラウドコンテナに置いた JSON スナップショット 1 個」で
/// 成立するため、操作はそのファイルの読み書きと、その競合版の扱いだけに絞ってある。
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

  /// 未解決の競合版。無ければ空。
  ///
  /// ある端末が古い内容で上書きすると、他端末の新しい版は現行版から外れて
  /// 競合版として残る。[SyncService] はこれも取り込み、変更の取りこぼしを防ぐ。
  Future<List<CloudConflict>> readConflicts();

  /// [readConflicts] で得た競合版のうち、[ids] のものだけを解決済みにして消す。
  ///
  /// id で指定するのは、読み取り後に届いた(まだ取り込んでいない)競合版を
  /// 巻き込んで消さないため。
  Future<void> resolveConflicts(List<String> ids);
}

/// 同期ファイルの競合版 1 つ。
class CloudConflict {
  const CloudConflict({
    required this.id,
    required this.contents,
    required this.modifiedAt,
  });

  /// [CloudFileStore.resolveConflicts] に渡す識別子。
  final String id;

  /// 競合版のファイル内容(同期ファイルと同じ JSON)。
  final String contents;

  /// 競合版が書かれた日時。取れなければ null。
  final DateTime? modifiedAt;
}

/// クラウドが使えないときの失敗。
///
/// 文言は持たせず、[reason] から表示側(syncFailureText)が言語に合わせて出す。
/// [detail] は OS が返した説明など、理由だけでは伝わらない補足(あれば)。
class CloudUnavailableException implements Exception {
  const CloudUnavailableException(this.reason, [this.detail]);

  final CloudFailureReason reason;
  final String? detail;

  @override
  String toString() => detail ?? reason.name;
}

/// 同期が失敗した理由。
enum CloudFailureReason {
  /// iCloud Drive にサインインしていないなど、iCloud を使えない。
  noICloud,

  /// 端末のコピーを最新化できず、同期を見送った([CloudNotReadyException])。
  notCurrent,

  /// iCloud に対応していないプラットフォーム。
  unsupportedPlatform,

  /// それ以外(読み書きの失敗など)。
  failed,
}

/// 端末のコピーがクラウドの最新版にならず、同期を見送ったときの失敗。
///
/// 古いコピーを読んで書き戻すと、他端末の新しい版を踏み潰して競合版に追いやるため、
/// 最新化を待ちきれなかったときは読み書きせずにこれを投げる。
/// 一時的な状態なので、[SyncNotifier] は少し待って再試行する。
class CloudNotReadyException extends CloudUnavailableException {
  const CloudNotReadyException([String? detail])
    : super(CloudFailureReason.notCurrent, detail);
}
