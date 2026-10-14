import 'package:flutter/foundation.dart';

/// 計測まわりのデバッグログ。
///
/// debug ビルドは Firebase を初期化せず何も送らないため(analytics_initializer
/// 参照)、送るはずだったイベントとパラメータをここに出して Dev ビルドで
/// 確かめられるようにする。広告(`adLog`)と同じく、リリースビルドでは何も出さない。
void analyticsLog(String message) {
  if (kDebugMode) debugPrint('[analytics] $message');
}
