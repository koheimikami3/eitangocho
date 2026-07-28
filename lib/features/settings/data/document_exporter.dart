import 'package:flutter/services.dart';

/// iOS の書き出しパネル(UIDocumentPickerViewController)を開く。
///
/// file_selector_ios は openFile / openFiles しか実装しておらず、macOS 版で
/// 使っている `getSaveLocation` が無い(呼ぶと UnimplementedError になる)。
/// 必要なのは 1 ファイルの書き出しだけなので、iCloud 同期と同じ方針で
/// 自前の MethodChannel を持つ。ネイティブ側は
/// `ios/Runner/DocumentExportPlugin.swift`。
const _channel = MethodChannel('eitangocho/document_export');

/// [contents] を [suggestedName] という名前で、ユーザーが選んだ場所へ書き出す。
///
/// 保存できたら true、ユーザーがキャンセルしたら false を返す。
/// iOS 以外では呼ばないこと(チャネルが登録されていない)。
Future<bool> exportDocument({
  required String suggestedName,
  required String contents,
}) async {
  final saved = await _channel.invokeMethod<bool>('export', {
    'name': suggestedName,
    'contents': contents,
  });
  return saved ?? false;
}
