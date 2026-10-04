import 'package:eitangocho/features/settings/domain/translation_language.dart';
import 'package:url_launcher/url_launcher.dart';

/// 発音確認用の Google 翻訳 URL を生成する(全単語の発音確認導線)。
///
/// 訳先(`tl`)は訳の言語に合わせる。発音を聞くのが目的だが、ページには
/// 訳も並ぶため、利用者が読める言語にしておく。
Uri googleTranslateUrl(String word, TranslationLanguage language) => Uri.parse(
  'https://translate.google.com/?sl=en&tl=${language.googleTranslateCode}'
  '&text=${Uri.encodeComponent(word)}&op=translate',
);

/// Google 翻訳を外部ブラウザで開く。
///
/// macOS 版の発音確認はアプリ内の別ウィンドウ(openPronunciationWindow)で開き、
/// これはそのチャンネルが使えないときの予備にだけ使う。
///
/// **`LaunchMode.externalApplication` を明示するのが要点**。既定の
/// `platformDefault` は iOS では SFSafariViewController(アプリ内 Safari)に
/// なり、読み込みに失敗すると「完了」でも閉じられない画面に閉じ込められる。
/// 現状 macOS からしか呼ばないが、iOS に戻したときのために明示しておく。
Future<bool> openGoogleTranslateInBrowser(
  String word,
  TranslationLanguage language,
) => launchUrl(
  googleTranslateUrl(word, language),
  mode: LaunchMode.externalApplication,
);
