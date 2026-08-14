import 'package:eitangocho/features/settings/data/license_list_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

const mitText = '''
MIT License

Copyright (c) 2020 Someone

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction.
''';

const bsdText = '''
Copyright 2014 The Flutter Authors. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
''';

void main() {
  group('detectLicenseName', () {
    test('主要なライセンスを本文から判別する', () {
      expect(detectLicenseName(mitText), 'MIT License');
      expect(detectLicenseName(bsdText), 'BSD License');
      expect(
        detectLicenseName('Apache License\nVersion 2.0, January 2004'),
        'Apache License 2.0',
      );
      expect(detectLicenseName('CC0 1.0 Universal'), 'CC0 1.0 Universal');
      expect(
        detectLicenseName(
          'released under the Creative Commons Attribution-ShareAlike 4.0 '
          'International License',
        ),
        'CC BY-SA 4.0',
      );
    });

    test('改行や連続空白をまたいでも判別できる', () {
      expect(
        detectLicenseName('Permission is hereby granted,\n  free of charge'),
        'MIT License',
      );
    });

    test('判別できなければ null', () {
      expect(detectLicenseName('独自ライセンスです。'), isNull);
      expect(detectLicenseName(''), isNull);
    });
  });

  group('groupLicenses', () {
    test('パッケージ単位にまとめ、名前順に並べる', () {
      final items = groupLicenses([
        const LicenseEntryWithLineBreaks(['zebra'], mitText),
        const LicenseEntryWithLineBreaks(['alpha'], bsdText),
      ]);

      expect(items.map((i) => i.name), ['alpha', 'zebra']);
      expect(items.first.summary, 'BSD License');
      expect(items.last.summary, 'MIT License');
    });

    // 共通ライセンスは複数パッケージにまとめて登録されることがある。
    test('1 エントリが複数パッケージに紐づく場合は全部に配る', () {
      final items = groupLicenses([
        const LicenseEntryWithLineBreaks(['a', 'b'], mitText),
      ]);

      expect(items.map((i) => i.name), ['a', 'b']);
      expect(items.every((i) => i.summary == 'MIT License'), isTrue);
    });

    test('同じパッケージの複数ライセンスは 1 行にまとめる', () {
      final items = groupLicenses([
        const LicenseEntryWithLineBreaks(['dual'], mitText),
        const LicenseEntryWithLineBreaks(['dual'], bsdText),
      ]);

      expect(items, hasLength(1));
      expect(items.single.texts, hasLength(2));
      // 種別が割れるので件数表記に落ちる
      expect(items.single.summary, '2 件のライセンス');
    });

    test('種別が判別できない単一ライセンスは「ライセンス」と表示する', () {
      final items = groupLicenses([
        const LicenseEntryWithLineBreaks(['x'], '独自ライセンス'),
      ]);

      expect(items.single.summary, 'ライセンス');
    });

    test('本文が空のエントリは無視する', () {
      final items = groupLicenses([
        const LicenseEntryWithLineBreaks(['empty'], '   '),
        const LicenseEntryWithLineBreaks(['ok'], mitText),
      ]);

      expect(items.map((i) => i.name), ['ok']);
    });

    test('パッケージ名の大文字小文字は並び順に影響しない', () {
      final items = groupLicenses([
        const LicenseEntryWithLineBreaks(['Zebra'], mitText),
        const LicenseEntryWithLineBreaks(['alpha'], mitText),
      ]);

      expect(items.map((i) => i.name), ['alpha', 'Zebra']);
    });
  });
}
