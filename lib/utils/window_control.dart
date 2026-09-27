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

Future<void> _invoke(String method) async {
  try {
    await _channel.invokeMethod<void>(method);
  } on MissingPluginException {
    // チャンネルが無い環境(テストなど)では何もしない。
  }
}
