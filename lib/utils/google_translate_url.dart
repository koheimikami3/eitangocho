/// 発音確認用の Google 翻訳 URL を生成する
/// (辞書 API の audio が無い単語のフォールバック先)。
Uri googleTranslateUrl(String word) => Uri.parse(
  'https://translate.google.com/?sl=en&tl=ja'
  '&text=${Uri.encodeComponent(word)}&op=translate',
);
