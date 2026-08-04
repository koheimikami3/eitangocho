import 'package:eitangocho/components/mobile_sheet.dart';
import 'package:eitangocho/components/pronunciation_web_view.dart';
import 'package:eitangocho/utils/google_translate_url.dart';
import 'package:flutter/material.dart';

/// iOS 版の発音確認シート。Google 翻訳をアプリ内の WebView で開く。
///
/// 単語の編集シートと同じ枠([MobileSheet])に載せる。外部ブラウザに飛ばすと
/// 学習が途切れるためアプリ内に留めるが、Google 側の制限で表示・再生が
/// できないときのために「ブラウザで開く」を右上に残す。
Future<void> showMobilePronunciationSheet(
  BuildContext context,
  String word,
) {
  return showMobileSheet<void>(
    context: context,
    builder: (sheetContext) => MobileSheet(
      title: word,
      leftLabel: '閉じる',
      onLeft: () => Navigator.of(sheetContext).pop(),
      rightLabel: 'ブラウザで開く',
      onRight: () => openGoogleTranslateInBrowser(word),
      // WebView 自身が残り高いっぱいに広がるため、スクロール枠には載せない。
      scrollableBody: false,
      child: PronunciationWebView(word: word),
    ),
  );
}
