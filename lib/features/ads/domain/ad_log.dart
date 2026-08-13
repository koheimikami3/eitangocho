import 'package:flutter/foundation.dart';

/// 広告まわりのデバッグログ。
///
/// 広告は「出ない」が正常系(在庫切れ・SDK 未初期化・ID 未設定)と区別が
/// つかないうえ、動作確認が実機・シミュレータでしかできない。失敗を黙って
/// 握ると原因を追う手段が無くなるため、経路の要所でここに流す。
/// リリースビルドでは何も出さない。
void adLog(String message) {
  if (kDebugMode) debugPrint('[ads] $message');
}
