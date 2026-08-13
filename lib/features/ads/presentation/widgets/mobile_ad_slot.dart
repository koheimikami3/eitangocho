import 'dart:async';

import 'package:eitangocho/features/ads/data/ads_provider.dart';
import 'package:eitangocho/features/ads/domain/ad_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 広告 1 枠の読み込み・破棄・再試行をまとめた土台(iOS のみ)。
///
/// 3 つの枠(タブバー上・シート内・クイズ結果)で共通するのはここまでで、
/// 見た目と置き場所は [builder] に任せる。読み込めるまでは、また広告ユニット
/// ID が未設定のときは何も描かない(先に空の枠を置くと、広告が付かない端末に
/// 意味の無い帯が残るため)。
///
/// このウィジェットをツリーから外せば広告も破棄される。シートに覆われている
/// 間や、キーボードで隠れる間の消し方は呼び出し側がそれで表現する。
class MobileAdSlot extends ConsumerStatefulWidget {
  const MobileAdSlot({
    required this.adUnitId,
    required this.resolveSize,
    required this.builder,
    this.onSizeChanged,
    super.key,
  });

  /// AdMob の広告ユニット ID。空なら何もしない(未作成のユニットを配線しても
  /// 落ちないようにするための保険。`AdUnitIds` 参照)。
  final String adUnitId;

  /// 要求する広告サイズを決める。端末幅から決まるアダプティブバナーは
  /// ネイティブに問い合わせるため非同期。null を返したら枠ごと出さない。
  final Future<AdSize?> Function(BuildContext context) resolveSize;

  /// 読み込めた広告の描画。[adView] は広告そのもの(サイズ確定済み)で、
  /// 背景・境界線・余白といった枠の装飾は呼び出し側が被せる。
  final Widget Function(BuildContext context, Widget adView) builder;

  /// 表示中の広告サイズの変化。読み込み前・破棄後は null が渡る。
  /// 枠の高さぶんレイアウトを空けたい側(タブバー上のバナー)が使う。
  final ValueChanged<AdSize?>? onSizeChanged;

  @override
  ConsumerState<MobileAdSlot> createState() => _MobileAdSlotState();
}

class _MobileAdSlotState extends ConsumerState<MobileAdSlot> {
  BannerAd? _ad;

  /// 読み込みを二重に走らせないためのフラグ。
  var _requesting = false;

  /// 読み込み失敗後の再試行。通信断は一時的なことが多いのに、1 回失敗した
  /// きりだと次に画面が作り直されるまでずっと空のままになる。
  Timer? _retryTimer;
  var _retryCount = 0;

  /// 再試行の上限。これを超えたら次にこの枠が作り直されるまで諦める
  /// (在庫切れのときに延々とリクエストを投げても仕方がない)。
  static const _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    // 最初のフレームを描いてから読み込む。ATT のダイアログはアプリが
    // アクティブになる前に要求しても表示されないまま返ってしまう。
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAd());
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _ad?.dispose();
    super.dispose();
  }

  /// 失敗した読み込みを間隔を空けて試し直す(10 秒 → 20 秒 → 40 秒)。
  void _scheduleRetry() {
    if (_retryCount >= _maxRetries) {
      adLog('再試行の上限に達したので諦めます(${widget.adUnitId})');
      return;
    }
    final delay = Duration(seconds: 10 * (1 << _retryCount));
    _retryCount++;
    adLog('${delay.inSeconds} 秒後に再試行します($_retryCount/$_maxRetries)');
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      if (mounted) _loadAd();
    });
  }

  Future<void> _loadAd() async {
    if (_ad != null || _requesting) return;
    if (widget.adUnitId.isEmpty) {
      adLog('広告ユニット ID が空のためこの枠は出しません');
      return;
    }
    _requesting = true;
    try {
      if (!await ref.read(adsEnabledProvider.future)) return;
      if (!mounted) return;

      final size = await widget.resolveSize(context);
      // 端末に合うサイズが無ければ広告そのものを諦める(枠も出さない)。
      if (size == null) {
        adLog('広告サイズを決められませんでした(${widget.adUnitId})');
        return;
      }
      if (!mounted) return;
      adLog('読み込み開始: ${size.width}x${size.height} / ${widget.adUnitId}');

      await BannerAd(
        adUnitId: widget.adUnitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            adLog('読み込み成功: ${widget.adUnitId}');
            _retryCount = 0;
            // 読み込み中に画面から消えたなら出さずに捨てる。
            if (!mounted) {
              ad.dispose();
              return;
            }
            setState(() => _ad = ad as BannerAd);
            widget.onSizeChanged?.call(size);
          },
          // 在庫切れ・通信断など。通信断は一時的なことが多いので数回試す。
          onAdFailedToLoad: (ad, error) {
            adLog('読み込み失敗: $error');
            ad.dispose();
            if (mounted) _scheduleRetry();
          },
        ),
      ).load();
    } finally {
      _requesting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null) return const SizedBox.shrink();

    return widget.builder(
      context,
      SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
