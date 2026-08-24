import 'package:eitangocho/features/ads/data/tracking_authorizer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fake_tracking_client.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  late FakeTrackingClient client;
  late TrackingAuthorizer authorizer;

  /// 待ち時間は本番値のままだとテストが止まるので縮める。
  /// [activationTimeout] は「待ちきれずに諦める」経路を見るときだけ短くする
  /// (既定を短くすると、他のテストが復帰を待てずに偶然通ってしまう)。
  TrackingAuthorizer create({
    Duration activationTimeout = const Duration(seconds: 5),
  }) => TrackingAuthorizer(
    client: client,
    activationDelay: Duration.zero,
    activationTimeout: activationTimeout,
  );

  /// アクティブでない状態から復帰させる。`resumed` へ直接飛ばすと
  /// [AppLifecycleListener] が遷移として認識しない。
  Future<void> resume() async {
    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpEventQueue();
  }

  setUp(() {
    client = FakeTrackingClient();
    authorizer = create();
  });

  tearDown(() {
    authorizer.dispose();
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  test('回答済みならダイアログを出さない', () async {
    client.settled = true;

    await authorizer.ensureRequested();

    expect(client.requestCount, 0);
  });

  test('アプリがアクティブになるまで要求しない', () async {
    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    // 非アクティブのまま作り直さないと、待ちに入る前の状態を再現できない。
    authorizer.dispose();
    authorizer = create();

    final requested = authorizer.ensureRequested();
    await pumpEventQueue();
    // ここで要求してしまうのが 1.5.0 (5) のリジェクト原因。
    expect(client.requestCount, 0);

    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await requested;

    expect(client.requestCount, 1);
  });

  test('アクティブ化を待ちきれなくても、諦めて要求はする', () async {
    binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    authorizer.dispose();
    authorizer = create(activationTimeout: const Duration(milliseconds: 10));

    // 復帰が来ないまま止まり続けると広告がゼロになる。上限で先へ進む。
    await authorizer.ensureRequested();

    expect(client.requestCount, 1);
  });

  test('ダイアログが出なかったら次にアクティブへ戻ったときに出し直す', () async {
    client.dialogShows = false;

    await authorizer.ensureRequested();
    expect(client.requestCount, 1);

    // 2 回目は出せた、という状況にする。
    client.dialogShows = true;
    await resume();

    expect(client.requestCount, 2);
    expect(client.settled, isTrue);
  });

  test('回答が済んだらアクティブへ戻っても要求し直さない', () async {
    await authorizer.ensureRequested();
    expect(client.requestCount, 1);

    await resume();

    expect(client.requestCount, 1);
  });

  test('同時に呼ばれても要求は 1 回だけ', () async {
    await Future.wait([
      authorizer.ensureRequested(),
      authorizer.ensureRequested(),
    ]);

    expect(client.requestCount, 1);
  });

  test('要求が例外を投げてもアプリを止めず、繰り返し叩きにも行かない', () async {
    client.requestError = Exception('プラグインがありません');

    // 例外が呼び出し側まで漏れない(広告 SDK の初期化へ進める)。
    await authorizer.ensureRequested();
    expect(client.requestCount, 1);

    await resume();

    // 直らない失敗なので、アクティブに戻るたびに叩き続けない。
    expect(client.requestCount, 1);
  });
}
