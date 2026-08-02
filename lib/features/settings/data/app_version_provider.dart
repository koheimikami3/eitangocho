import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_version_provider.g.dart';

/// 表示用のアプリバージョン(`1.1.0` 形式)。
///
/// pubspec の値を macOS / iOS の両方が読むため、ここもネイティブのバンドルから
/// 取る(定数で持つと pubspec と二重管理になり、上げ忘れる)。
@riverpod
Future<String> appVersion(Ref ref) async =>
    (await PackageInfo.fromPlatform()).version;
