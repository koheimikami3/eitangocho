import 'package:eitangocho/constants/app_palette.dart';
import 'package:eitangocho/utils/google_translate_url.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 発音確認用に Google 翻訳を表示する WebView(機能横断コンポーネント)。
///
/// iOS はボトムシート([showMobilePronunciationSheet])、macOS はダイアログ
/// ([showPronunciationDialog])の中身として使う。枠は違うが読み込み・エラー
/// 表示は同じなので、ここだけ共有する。
///
/// 配色は macOS / iOS とも [AppPalette] から引く(macOS のテーマはライト固定で
/// 組まれているため、`context.palette` はライトを返す)。
class PronunciationWebView extends StatefulWidget {
  const PronunciationWebView({required this.word, super.key});

  final String word;

  @override
  State<PronunciationWebView> createState() => _PronunciationWebViewState();
}

class _PronunciationWebViewState extends State<PronunciationWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  /// 一度でも読み込みが完了したか。完了後の失敗でページを捨てないための判定。
  bool _hasRendered = false;

  /// 読み込みの中断(NSURLErrorCancelled)。WKWebView は遷移が差し替わるたびに
  /// この失敗を通知してくるため、Google 翻訳のリダイレクトでも普通に飛んでくる。
  /// 「読み込めなかった」ではないのでエラー扱いしない。
  static const _nsUrlErrorCancelled = -999;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      // Google 翻訳は JS 無しでは発音ボタンも訳文も出ない。
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => _update(loading: true, error: false),
          onPageFinished: (_) {
            _hasRendered = true;
            _update(loading: false, error: false);
          },
          onWebResourceError: (error) {
            if (error.errorCode == _nsUrlErrorCancelled) return;
            // 表示できているのに、後続の失敗で白紙に戻さない
            // (広告・計測の読み込み失敗でページごと消える方が困る)。
            if (_hasRendered) return;
            _update(loading: false, error: true);
          },
        ),
      )
      ..loadRequest(googleTranslateUrl(widget.word));
  }

  void _update({required bool loading, bool? error}) {
    if (!mounted) return;
    setState(() {
      _isLoading = loading;
      if (error != null) _hasError = error;
    });
  }

  void _reload() {
    _update(loading: true, error: false);
    _controller.loadRequest(googleTranslateUrl(widget.word));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ページを読み込めませんでした。\n通信状況を確認してから、もう一度お試しください。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: palette.textAlpha(60),
                ),
              ),
              const SizedBox(height: 16),
              // 一時的な失敗で閉じ直させないよう、その場で引き直せるようにする。
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _reload,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    '再読み込み',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: palette.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          // 読み込み中は白紙が見えるため、面の色で覆ってインジケータを出す。
          Positioned.fill(
            child: ColoredBox(
              color: palette.surface,
              child: Center(
                // 色を指定しないと ColorScheme.primary(seed から導出された
                // 濃紺)になり、アプリのアクセント色と違う色が出る。
                child: CircularProgressIndicator(color: palette.accent),
              ),
            ),
          ),
      ],
    );
  }
}
