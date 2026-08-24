import 'dart:async';

import 'package:eitangocho/features/ads/data/tracking_client.dart';
import 'package:eitangocho/features/ads/domain/ad_log.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ATT(トラッキング許可)を「いつ要求するか」を決める。
///
/// **アプリがアクティブ(シーンが foregroundActive)になるまで要求しない。**
/// iOS 15 以降、非アクティブ中に要求してもダイアログは出ず、現在の状態が
/// そのまま返るだけで終わる。1.5.0 (5) が Guideline 2.1 でリジェクトされたのは
/// これで、当時は広告枠の最初のフレーム(`addPostFrameCallback`)で要求していた。
/// 「最初のフレームを描いた」は「アクティブになった」ではない。
///
/// ダイアログが出せなかったときは、以後アクティブに戻るたびに要求し直す。
/// 1 回の起動で 1 回きりにすると、出せなかった起動では誰も拾わない。
///
/// **ATT の失敗でアプリを止めない**(辞書・広告・レビューと同じ方針)。
/// 例外は握ってログに流すだけにする。最悪でも非パーソナライズ広告は出せる。
class TrackingAuthorizer {
  /// [activationDelay] と [activationTimeout] は既定値が本番値で、
  /// テストからだけ縮める(`ReviewPrompter.promptDelay` と同じ)。
  TrackingAuthorizer({
    required this.client,
    this.activationDelay = const Duration(milliseconds: 500),
    this.activationTimeout = const Duration(seconds: 10),
  }) {
    _lifecycle = AppLifecycleListener(onResume: _onResume);
  }

  final TrackingClient client;

  /// アクティブになってから要求するまでの待ち時間。
  ///
  /// アクティブ化の直後はシステムのオーバーレイ(インストール直後の UI や
  /// TestFlight のシート)が消え切っていないことがあり、そこに重ねると
  /// ATT はやはり黙って出ないまま返る。ひと呼吸置いてから要求する。
  final Duration activationDelay;

  /// アクティブになるのを待つ上限。
  ///
  /// [WidgetsBinding.lifecycleState] が null のまま `onResume` も来ない環境で
  /// 永久に止まらないための保険。ここで諦めて要求し、それでも出なければ
  /// 次にアクティブへ戻ったときに出し直される。
  final Duration activationTimeout;

  late final AppLifecycleListener _lifecycle;

  /// 許可の状態が確定したか(= もうダイアログを出す必要がないか)。
  var _settled = false;

  /// ダイアログを出せなかったので、次にアクティブへ戻ったら出し直すか。
  var _retryOnResume = false;

  /// 実行中の要求。二重に走らせないために持つ。
  ///
  /// **ATT を重ねて呼ぶと以後ダイアログが出なくなる**(1 回目が非アクティブ中
  /// だった場合に顕著)。以前あった `.timeout(5 秒)` は、ネイティブ側の要求を
  /// 残したまま Dart だけ先に進むため、再試行と組み合わせるとまさにこれを
  /// 踏む。だから打ち切らずに単一化する。
  Future<void>? _inFlight;

  /// アクティブ化を待っている間だけ非 null。
  Completer<void>? _awaitingActivation;

  void dispose() {
    _lifecycle.dispose();
    // 待っている最中に破棄されたら、待ち手を取り残さない。
    final awaiting = _awaitingActivation;
    if (awaiting != null && !awaiting.isCompleted) awaiting.complete();
    _awaitingActivation = null;
  }

  /// 必要なら ATT のダイアログを出す。確定するか、出せないと分かるまで待つ。
  ///
  /// 出せなかった場合も戻る(呼び出し側は広告 SDK の初期化へ進んでよい)。
  /// トラッキング未許可として非パーソナライズ広告が出るだけで、ダイアログは
  /// 次にアクティブへ戻ったときに出し直される。
  Future<void> ensureRequested() {
    if (_settled) return Future<void>.value();
    return _inFlight ??= _run().whenComplete(() => _inFlight = null);
  }

  Future<void> _run() async {
    try {
      if (await client.isSettled()) {
        _settled = true;
        _retryOnResume = false;
        adLog('ATT は回答済みのため要求しません');
        return;
      }

      await _waitUntilActive();

      _settled = await client.request();
      _retryOnResume = !_settled;
      adLog(
        _settled
            ? 'ATT のダイアログに回答がありました'
            : 'ATT のダイアログが出ませんでした。次にアクティブへ戻ったら出し直します',
      );
    } on Object catch (error, stackTrace) {
      // 再試行フラグは立てない。プラグイン未登録のような直らない失敗だと、
      // アクティブに戻るたびに叩き続けることになるため。
      adLog('ATT の要求に失敗: $error\n$stackTrace');
    }
  }

  Future<void> _waitUntilActive() async {
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      adLog('アプリがアクティブになるのを待ちます');
      final awaiting = _awaitingActivation = Completer<void>();
      await awaiting.future.timeout(
        activationTimeout,
        onTimeout: () => adLog('アクティブ化を待ちきれませんでした。そのまま要求します'),
      );
      _awaitingActivation = null;
    }
    if (activationDelay > Duration.zero) {
      await Future<void>.delayed(activationDelay);
    }
  }

  void _onResume() {
    // アクティブ化待ちの最中ならそれを解く。
    final awaiting = _awaitingActivation;
    if (awaiting != null) {
      if (!awaiting.isCompleted) awaiting.complete();
      return;
    }
    if (_settled || !_retryOnResume || _inFlight != null) return;
    adLog('アクティブに戻ったので ATT を要求し直します');
    unawaited(ensureRequested());
  }
}

/// 待ち時間をテストから縮められるよう、Provider は手書きにする
/// ([reviewPrompterProvider] と同じ)。
final trackingAuthorizerProvider = Provider<TrackingAuthorizer>((ref) {
  final authorizer = TrackingAuthorizer(client: ref.watch(trackingClientProvider));
  ref.onDispose(authorizer.dispose);
  return authorizer;
});
