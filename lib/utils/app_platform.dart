import 'package:flutter/foundation.dart';

/// プラットフォーム差分の判定を 1 箇所に集約する。
///
/// `dart:io` の `Platform` ではなく `defaultTargetPlatform` を使うのは、
/// ウィジェットテストで `debugDefaultTargetPlatformOverride` により
/// 両プラットフォームの分岐を検証できるようにするため。
abstract final class AppPlatform {
  /// macOS 版か。ポインタ操作前提の UI(サイドバーシェル・ネイティブ
  /// メニューバー・UI 全体の拡大)はこちらでのみ有効にする。
  static bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  /// iOS 版か。タッチ操作前提の UI(タブバーシェル・長押しメニュー)を使う。
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
}
