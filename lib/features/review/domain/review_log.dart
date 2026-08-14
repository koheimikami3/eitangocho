import 'package:flutter/foundation.dart';

/// レビュー依頼まわりのデバッグログ。
///
/// 広告([adLog])・課金と同じ理由で置く。レビュー依頼は「出ない」が正常系
/// (OS のクォータ超過・ユーザーが設定で無効化)と区別がつかず、ダイアログ自体は
/// ストア配布版でしか出ない。失敗も条件落ちも黙って握ると原因を追う手段が
/// 無くなるため、判定の経路をログに残す。リリースビルドでは何も出さない。
void reviewLog(String message) {
  if (kDebugMode) debugPrint('[review] $message');
}
