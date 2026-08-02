import 'package:eitangocho/features/settings/domain/license_item.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'license_list_provider.g.dart';

/// ライセンス全文からライセンス名を判別する。判別できなければ null。
///
/// Flutter の [LicenseEntry] は本文しか持たず種別を教えてくれないため、
/// 一覧の副題(`MIT License` など)は本文から推測するしかない。
/// 判別できないものは件数表記に落とすので、当てにいきすぎない。
String? detectLicenseName(String text) {
  final head = text.length > 1200 ? text.substring(0, 1200) : text;
  final normalized = head.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  const patterns = <String, String>{
    'permission is hereby granted, free of charge': 'MIT License',
    'redistribution and use in source and binary forms': 'BSD License',
    'apache license': 'Apache License 2.0',
    'sil open font license': 'SIL Open Font License 1.1',
    'mozilla public license': 'Mozilla Public License 2.0',
    'gnu general public license': 'GNU General Public License',
    'gnu lesser general public license': 'GNU Lesser General Public License',
    'cc0 1.0 universal': 'CC0 1.0 Universal',
    'creative commons attribution-sharealike 4.0': 'CC BY-SA 4.0',
    'cc-by 2.0 fr': 'CC BY 2.0 FR',
  };
  for (final entry in patterns.entries) {
    if (normalized.contains(entry.key)) return entry.value;
  }
  return null;
}

/// [LicenseRegistry] のエントリをパッケージ単位にまとめる。
///
/// 1 エントリが複数パッケージに紐づくことがあるため(共通ライセンスの
/// まとめ登録)、パッケージごとに本文を集め直す。並びは名前順。
List<LicenseItem> groupLicenses(List<LicenseEntry> entries) {
  final byPackage = <String, List<String>>{};
  for (final entry in entries) {
    final text = entry.paragraphs.map((p) => p.text.trim()).join('\n\n').trim();
    if (text.isEmpty) continue;
    for (final package in entry.packages) {
      byPackage.putIfAbsent(package, () => []).add(text);
    }
  }

  final items = [
    for (final entry in byPackage.entries)
      LicenseItem(
        name: entry.key,
        summary: _summaryOf(entry.value),
        texts: entry.value,
      ),
  ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return items;
}

/// 判別できた種別が 1 つに定まればその名前、そうでなければ件数表記。
String _summaryOf(List<String> texts) {
  // 判別できなかった本文が 1 つでも混ざれば null が要素に残り、名前は使わない。
  final names = texts.map(detectLicenseName).toSet();
  final single = names.length == 1 ? names.first : null;
  if (single != null) return single;
  return texts.length == 1 ? 'ライセンス' : '${texts.length} 件のライセンス';
}

/// ライセンス一覧。[LicenseRegistry.licenses] は Stream なので読み切ってから返す。
@riverpod
Future<List<LicenseItem>> licenseList(Ref ref) async =>
    groupLicenses(await LicenseRegistry.licenses.toList());
