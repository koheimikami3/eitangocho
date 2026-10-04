import 'package:freezed_annotation/freezed_annotation.dart';

part 'license_item.freezed.dart';

/// ライセンス一覧の 1 行。パッケージ(またはデータソース)単位でまとめる。
@freezed
abstract class LicenseItem with _$LicenseItem {
  const factory LicenseItem({
    required String name,

    /// 一覧に出す種別(`MIT License` など)。判別できなければ null で、
    /// 表示側が件数表記(licenseCount)に置き換える。
    required String? summary,

    /// 詳細画面に出す全文。1 要素 = 1 ライセンス。
    required List<String> texts,
  }) = _LicenseItem;
}
