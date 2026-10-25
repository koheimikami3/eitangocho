import 'package:flutter/services.dart';

const _channel = MethodChannel('eitangocho/window');

/// 本体ウィンドウのドラッグ移動を始める(macOS 専用)。
///
/// 実処理はネイティブ側(macos/Runner/WindowControlPlugin.swift)。
/// ドラッグを検知した直後に呼ぶと、以降の移動は OS が追従する。
Future<void> startWindowDrag() => _invoke('startDrag');

/// タイトルバーをダブルクリックしたときの標準動作をする(macOS 専用)。
/// システム設定に従い、拡大 / 元に戻す・しまう・何もしない のいずれかになる。
Future<void> handleTitleBarDoubleClick() => _invoke('titleBarDoubleClick');

/// アプリの外観(ライト / ダーク)をネイティブ側にも伝える(macOS 専用)。
///
/// Flutter が描く部分はテーマで切り替わるが、信号機ボタン・ファイル選択パネル・
/// 発音確認のウィンドウ枠など AppKit が描く部分は NSApp.appearance に従うため。
Future<void> setWindowAppearance({required bool dark}) =>
    _invoke('setAppearance', dark);

Future<void> _invoke(String method, [Object? arguments]) async {
  try {
    await _channel.invokeMethod<void>(method, arguments);
  } on MissingPluginException {
    // チャンネルが無い環境(テストなど)では何もしない。
  }
}
