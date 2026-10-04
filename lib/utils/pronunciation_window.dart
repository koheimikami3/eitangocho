import 'package:eitangocho/features/settings/domain/translation_language.dart';
import 'package:eitangocho/utils/google_translate_url.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('eitangocho/pronunciation');

/// macOS 版の発音確認。Google 翻訳をアプリ内の別ウィンドウで開く。
///
/// 実処理はネイティブ側(macos/Runner/PronunciationWindowPlugin.swift)。
/// Flutter の画面に WebView を埋め込むと macOS では再生ボタンを押せないため、
/// ネイティブのウィンドウに WKWebView を置いている(docs/design.md 参照)。
/// チャンネルが無い環境(テストなど)では外部ブラウザで開く。
///
/// [zoom] はページの拡大率(1.0 で等倍)。アプリの uiScale を渡し、
/// ページの文字をアプリ本体と同じ大きさに揃える。
Future<void> openPronunciationWindow(
  String word,
  TranslationLanguage language, {
  double zoom = 1,
}) async {
  try {
    await _channel.invokeMethod<void>('open', {
      'url': googleTranslateUrl(word, language).toString(),
      'title': word,
      'zoom': zoom,
    });
  } on MissingPluginException {
    await openGoogleTranslateInBrowser(word, language);
  }
}
