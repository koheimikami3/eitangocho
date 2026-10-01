import 'package:eitangocho/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase Analytics の計測を始める。
///
/// 送るのは SDK の自動収集イベント(first_open / session_start /
/// user_engagement)だけで、アクティブユーザー数を測るのが目的。自動収集は
/// Firebase の初期化だけで始まるため、Analytics の API は呼ばない。
///
/// debug ビルドでは初期化しない。debug は Bundle ID に `.dev` が付いた別アプリで、
/// Firebase に登録した本番の Bundle ID と食い違ううえ、開発中の起動が本番の
/// 計測に混ざるため(dev 用の Firebase プロジェクトは持たない)。
///
/// 計測できなくても単語帳としては使えるべきなので、失敗は握って諦める
/// (広告・課金と同じ方針)。
Future<void> initializeAnalytics() async {
  if (kDebugMode) return;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    // ここは debug では通らないので、adLog のような debug 限定のログでは
    // 何も残らない。debugPrint は release でも止まらないので直接使う。
    debugPrint('[analytics] Firebase の初期化に失敗: $error\n$stackTrace');
  }
}
