/// WordInfoProvider の取得失敗(ネットワーク・API エラー等)。
/// 「辞書に未収録」は例外ではなく fetch の null 返却で表現する。
class WordInfoException implements Exception {
  const WordInfoException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'WordInfoException: $message';
}
