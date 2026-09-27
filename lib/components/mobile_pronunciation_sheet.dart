import 'package:eitangocho/components/mobile_pronunciation_web_view.dart';
import 'package:eitangocho/components/mobile_sheet.dart';
import 'package:flutter/material.dart';

/// iOS 版の発音確認シート。Google 翻訳をアプリ内の WebView で開く。
///
/// 単語の編集シートと同じ枠([MobileSheet])に載せる。外部ブラウザに飛ばすと
/// 学習が途切れるため、確認はアプリ内で完結させる。
Future<void> showMobilePronunciationSheet(BuildContext context, String word) {
  return showMobileSheet<void>(
    context: context,
    builder: (sheetContext) => MobileSheet(
      title: word,
      titleFontSize: 17,
      leftLabel: '閉じる',
      onLeft: () => Navigator.of(sheetContext).pop(),
      // WebView 自身が残り高いっぱいに広がるため、スクロール枠には載せない。
      scrollableBody: false,
      showGrabber: false,
      child: MobilePronunciationWebView(word: word),
    ),
  );
}
