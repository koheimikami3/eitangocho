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

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      // Google 翻訳は JS 無しでは発音ボタンも訳文も出ない。
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => _update(loading: true, error: false),
          onPageFinished: (_) => _update(loading: false),
          onWebResourceError: (error) {
            // 画像 1 枚の失敗などでエラー画面に落とさない。
            if (error.isForMainFrame ?? true) {
              _update(loading: false, error: true);
            }
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

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'ページを読み込めませんでした。\n通信状況を確認するか、ブラウザで開いてください。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: palette.textAlpha(60),
            ),
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
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
