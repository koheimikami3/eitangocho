import 'package:url_launcher/url_launcher.dart';

/// 発音確認用の Google 翻訳 URL を生成する(全単語の発音確認導線)。
Uri googleTranslateUrl(String word) => Uri.parse(
  'https://translate.google.com/?sl=en&tl=ja'
  '&text=${Uri.encodeComponent(word)}&op=translate',
);

/// Google 翻訳を外部ブラウザで開く(macOS 版の発音確認導線)。
///
/// iOS はアプリ内の WebView で完結するが、macOS は platform view の制約で
/// WebView 内を操作できないため外部ブラウザに出す(docs/design.md 参照)。
///
/// **`LaunchMode.externalApplication` を明示するのが要点**。既定の
/// `platformDefault` は iOS では SFSafariViewController(アプリ内 Safari)に
/// なり、読み込みに失敗すると「完了」でも閉じられない画面に閉じ込められる。
/// 現状 macOS からしか呼ばないが、iOS に戻したときのために明示しておく。
Future<bool> openGoogleTranslateInBrowser(String word) =>
    launchUrl(googleTranslateUrl(word), mode: LaunchMode.externalApplication);
