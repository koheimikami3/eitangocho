import 'package:eitangocho/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase Analytics の計測を始める。初期化できたら true を返す。
///
/// SDK の自動収集イベント(first_open / session_start / user_engagement)は
/// 初期化だけで始まる。独自のイベントは `FirebaseAnalyticsClient` がこの
/// 戻り値を待ってから送る(false なら何も送らない)。
///
/// debug ビルドでは初期化しない。debug は Bundle ID に `.dev` が付いた別アプリで、
/// Firebase に登録した本番の Bundle ID と食い違ううえ、開発中の起動が本番の
/// 計測に混ざるため(dev 用の Firebase プロジェクトは持たない)。
///
/// 計測できなくても単語帳としては使えるべきなので、失敗は握って諦める
/// (広告・課金と同じ方針)。
Future<bool> initializeAnalytics() async {
  if (kDebugMode) return false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } catch (error, stackTrace) {
    // ここは debug では通らないので、adLog のような debug 限定のログでは
    // 何も残らない。debugPrint は release でも止まらないので直接使う。
    debugPrint('[analytics] Firebase の初期化に失敗: $error\n$stackTrace');
    return false;
  }
}
