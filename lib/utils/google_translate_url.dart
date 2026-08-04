import 'package:url_launcher/url_launcher.dart';

/// 発音確認用の Google 翻訳 URL を生成する(全単語の発音確認導線)。
Uri googleTranslateUrl(String word) => Uri.parse(
  'https://translate.google.com/?sl=en&tl=ja'
  '&text=${Uri.encodeComponent(word)}&op=translate',
);

/// Google 翻訳を外部ブラウザで開く(アプリ内 WebView からの逃げ道)。
///
/// **`LaunchMode.externalApplication` を明示するのが要点**。既定の
/// `platformDefault` は iOS では SFSafariViewController(アプリ内 Safari)に
/// なり、アプリ内 WebView と役割が重複するうえ、読み込みに失敗すると
/// 「完了」でも閉じられない画面に閉じ込められる。ここはアプリの外に
/// 出すための導線なので、本物のブラウザを開く。
Future<bool> openGoogleTranslateInBrowser(String word) =>
    launchUrl(googleTranslateUrl(word), mode: LaunchMode.externalApplication);
