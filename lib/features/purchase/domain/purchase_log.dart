import 'package:flutter/foundation.dart';

/// 課金まわりのデバッグログ。
///
/// 広告([adLog])と同じ理由で置く。課金は「買えない」が正常系
/// (キー未設定・商品が未承認・sandbox 未ログイン)と区別がつかず、動作確認も
/// 実機でしかできない。失敗を黙って握ると原因を追う手段が無くなる。
/// リリースビルドでは何も出さない。
void purchaseLog(String message) {
  if (kDebugMode) debugPrint('[purchase] $message');
}
