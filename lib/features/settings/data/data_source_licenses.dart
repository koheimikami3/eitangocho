import 'package:flutter/foundation.dart';

/// 辞書・例文データの出典を [LicenseRegistry] に登録する。
///
/// pub パッケージのライセンスは Flutter が自動収集するが、同梱データと
/// 外部 API 由来のデータは自分で足さないと一覧に出ない。CC BY / CC BY-SA は
/// **帰属表示が義務**で、有料化・広告表示でも免除されない(docs/design.md)。
///
/// 全文ではなく出典・ライセンス名・原文へのリンクを載せる形にしている
/// (CC のライセンス表示要件はこれで満たせる。全文を抱えると数十 KB になる)。
void registerDataSourceLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      ['Wiktionary / kaikki.org(発音記号・品詞・例文)'],
      'This app uses dictionary data extracted from the English Wiktionary '
      'by the Wiktextract project, distributed at kaikki.org.\n\n'
      'Wiktionary content is licensed under the Creative Commons '
      'Attribution-ShareAlike 4.0 International License (CC BY-SA 4.0) and '
      'the GNU Free Documentation License (GFDL).\n\n'
      'https://en.wiktionary.org/\n'
      'https://creativecommons.org/licenses/by-sa/4.0/\n\n'
      'Extraction: Tatu Ylonen, "Wiktextract: Wiktionary as Machine-Readable '
      'Structured Data", Proceedings of the 13th Conference on Language '
      'Resources and Evaluation (LREC), pp. 1317-1325, Marseille, 2022.\n'
      'https://kaikki.org/',
    );

    yield const LicenseEntryWithLineBreaks(
      ['Tatoeba(例文と対訳)'],
      'Sentences are from Tatoeba (https://tatoeba.org), released under '
      'CC-BY 2.0 FR.\n\n'
      'https://creativecommons.org/licenses/by/2.0/fr/',
    );

    yield const LicenseEntryWithLineBreaks(
      ['EJDict-hand(英和辞書データ)'],
      'This app bundles the EJDict-hand English-Japanese dictionary data, '
      'released into the public domain under CC0 1.0 Universal.\n\n'
      'https://github.com/kujirahand/EJDict\n'
      'https://creativecommons.org/publicdomain/zero/1.0/',
    );

    yield const LicenseEntryWithLineBreaks(
      ['Google 翻訳(発音の確認)'],
      'Pronunciation is checked by opening Google Translate in the system '
      'browser. No Google API is called from within this app.\n\n'
      'https://translate.google.com/',
    );
  });
}
