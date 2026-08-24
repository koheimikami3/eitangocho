import 'dart:async';

import 'package:eitangocho/features/purchase/data/purchases_client.dart';
import 'package:eitangocho/features/purchase/domain/purchase_log.dart';
import 'package:eitangocho/features/purchase/domain/purchase_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 「広告を非表示にする」買い切りの購入状態を持つ。
///
/// 状態の出所は 2 つある。SDK の更新通知([PurchasesClient.watchProUnlocked])と、
/// このアプリ自身の購入・復元。前者を張り続けるのは、返金・別端末での購入が
/// 購入導線を通らずに起きるため。
///
/// 課金の失敗でアプリを止めない(辞書・広告と同じ方針)。買えなければ
/// 広告が出たままになるだけで、単語帳としては使える。
class PurchaseNotifier extends Notifier<PurchaseState> {
  /// [messageDuration] は既定値が本番値で、テストからだけ縮める。
  PurchaseNotifier({this.messageDuration = const Duration(milliseconds: 2600)});

  /// 購入・復元の結果メッセージを出しておく時間(デザイン準拠)。
  final Duration messageDuration;

  Timer? _messageTimer;
  StreamSubscription<bool>? _proUnlocked;

  late final Future<void> _initialized;

  final _proUnlockedKnown = Completer<void>();

  /// 購入状態(entitlement)が一度でも分かったことを表す Future。
  ///
  /// 広告側が「Pro を買った人には ATT を聞かない」を実際に効かせるために待つ。
  /// [PurchaseState.proUnlocked] の初期値 false を鵜呑みにすると、購入者にも
  /// 毎起動トラッキング許可を求めてしまう。
  ///
  /// 価格の取得までは待たない([_initialized] との違い)。entitlement とは
  /// 別の問い合わせで、遅い方に引きずられると ATT がそのぶん遅れるため。
  ///
  /// 「分かった」には諦めも含む。課金が使えない環境・初期化の失敗・破棄でも
  /// 完了させる。待ち手を取り残すと広告そのものが出なくなる。
  Future<void> get proUnlockedKnown => _proUnlockedKnown.future;

  void _markProUnlockedKnown() {
    if (!_proUnlockedKnown.isCompleted) _proUnlockedKnown.complete();
  }

  @override
  PurchaseState build() {
    _initialized = _initialize();

    ref.onDispose(() {
      _messageTimer?.cancel();
      _proUnlocked?.cancel();
      _markProUnlockedKnown();
    });

    return PurchaseState(
      available: ref.read(purchasesClientProvider).isAvailable,
    );
  }

  /// SDK を初期化し、購入状態の購読と価格の取得を始める。
  ///
  /// 初期化に失敗したら購入も復元もできないため、Pro セクションごと畳む
  /// ([PurchaseState.available] を false に戻す)。押しても何も起きない
  /// ボタンを残すより、無い方が分かりやすい。
  Future<void> _initialize() async {
    final client = ref.read(purchasesClientProvider);
    if (!client.isAvailable) {
      purchaseLog('課金は無効です(iOS 以外、または SDK キーが未設定)');
      _markProUnlockedKnown();
      return;
    }

    try {
      await client.configure();
    } on Object catch (error) {
      purchaseLog('SDK の初期化に失敗しました: $error');
      if (ref.mounted) state = state.copyWith(available: false);
      _markProUnlockedKnown();
      return;
    }
    if (!ref.mounted) return;

    _proUnlocked = client.watchProUnlocked().listen((unlocked) {
      _markProUnlockedKnown();
      if (!ref.mounted) return;
      purchaseLog('購入状態: ${unlocked ? "Pro" : "未購入"}');
      state = state.copyWith(proUnlocked: unlocked);
    });

    final priceText = await client.fetchPriceText();
    if (!ref.mounted) return;
    state = state.copyWith(priceText: priceText);
  }

  /// 買い切り商品を購入する。
  ///
  /// 価格が取れていないときは呼ばない(商品が引けていない = 購入もできない)。
  Future<void> buy() async {
    await _initialized;
    if (!ref.mounted) return;
    if (!state.available || state.purchasing || state.proUnlocked) return;
    if (state.priceText == null) return;

    state = state.copyWith(purchasing: true, purchaseMessage: null);
    final outcome = await ref.read(purchasesClientProvider).purchase();
    if (!ref.mounted) return;

    switch (outcome) {
      case PurchaseOutcome.purchased:
        state = state.copyWith(purchasing: false, proUnlocked: true);
      // ダイアログを閉じただけなので何も出さない。
      case PurchaseOutcome.cancelled:
        state = state.copyWith(purchasing: false);
      case PurchaseOutcome.failed:
        state = state.copyWith(
          purchasing: false,
          purchaseMessage: '購入できませんでした',
        );
        _scheduleMessageClear();
    }
  }

  /// 過去の購入を復元する。
  ///
  /// 機種変更・再インストールで購入が消えた人のための導線なので、購入済みに
  /// 見えているかどうかに関わらず実行できる。結果は復元の判断そのもの
  /// (RevenueCat が返す entitlement)で上書きする。
  Future<void> restore() async {
    await _initialized;
    if (!ref.mounted) return;
    if (!state.available || state.restoring) return;

    state = state.copyWith(restoring: true, restoreMessage: '確認中…');
    try {
      final unlocked = await ref.read(purchasesClientProvider).restore();
      if (!ref.mounted) return;
      state = state.copyWith(
        restoring: false,
        proUnlocked: unlocked,
        restoreMessage: unlocked ? '復元しました' : '購入履歴が見つかりません',
      );
    } on Object catch (error) {
      purchaseLog('復元に失敗しました: $error');
      if (!ref.mounted) return;
      state = state.copyWith(restoring: false, restoreMessage: '復元できませんでした');
    }
    _scheduleMessageClear();
  }

  /// 一時表示のメッセージを消す。
  void _scheduleMessageClear() {
    _messageTimer?.cancel();
    _messageTimer = Timer(messageDuration, () {
      if (!ref.mounted) return;
      state = state.copyWith(purchaseMessage: null, restoreMessage: null);
    });
  }
}

/// メッセージの表示時間をテストから縮められるよう、Provider は手書きにする
/// (riverpod_generator の class 版はコンストラクタ引数を取れない。
/// syncProvider と同じ形)。
final purchaseProvider = NotifierProvider<PurchaseNotifier, PurchaseState>(
  PurchaseNotifier.new,
);
