/// 発音確認用の Google 翻訳 URL を生成する(全単語の発音確認導線)。
Uri googleTranslateUrl(String word) => Uri.parse(
  'https://translate.google.com/?sl=en&tl=ja'
  '&text=${Uri.encodeComponent(word)}&op=translate',
);
