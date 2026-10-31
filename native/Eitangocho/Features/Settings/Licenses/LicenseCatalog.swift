import Foundation

/// ライセンス一覧の元になる 1 件(Flutter の LicenseEntry に当たる)。
struct LicenseEntry: Sendable {
  /// 見出しに出す名前(パッケージ名・出典名・書体名)。1 件が複数に紐づくこともある。
  let packages: [String]
  let text: String
}

/// ライセンス一覧の 1 行。パッケージ(または出典)単位でまとめる(Flutter 版の LicenseItem)。
struct LicenseItem: Equatable, Identifiable, Sendable {
  let name: String
  /// 一覧に出す種別(`MIT License` など)。判別できなければ nil で、表示側が件数表記にする。
  let summary: String?
  /// 全文。1 要素 = 1 ライセンス。
  let texts: [String]

  var id: String { name }
}

/// ライセンス一覧(Flutter 版の license_list_provider.dart・data_source_licenses.dart・font_licenses.dart)。
///
/// Flutter 版はパッケージのライセンスをビルド時に集めていたが、SwiftPM には同じ仕組みが無いので、
/// 一覧は手で持つ: 辞書・例文の出典 + 同梱フォント + Swift パッケージ。
/// **Swift パッケージを足したら、その LICENSE を `Resources/Licenses/` に置き、`packages` に足す。**
enum LicenseCatalog {
  /// 同梱フォント(書体名, assets/fonts/licenses のファイル名)。SIL Open Font License は
  /// 著作権表示と本文をフォントと一緒に配ることが条件なので、全文を載せる。
  static let fonts = [
    ("Inter", "Inter-OFL"),
    ("Noto Sans JP", "NotoSansJP-OFL"),
    ("Noto Sans TC", "NotoSansTC-OFL"),
    ("Andika", "Andika-OFL"),
  ]

  /// Swift パッケージ(パッケージ名, Resources/Licenses のファイル名)。
  static let packages = [
    ("GRDB.swift", "GRDB.swift-LICENSE"),
    // FirebaseAnalytics と、それがリンクするパッケージ(解決結果の Package.resolved のうち、実際にリンクされるもの)。
    ("Firebase", "Firebase-LICENSE"),
    ("GoogleAppMeasurement", "GoogleAppMeasurement-LICENSE"),
    ("GoogleAdsOnDeviceConversion", "GoogleAdsOnDeviceConversion-LICENSE"),
    ("GoogleUtilities", "GoogleUtilities-LICENSE"),
    ("Promises", "Promises-LICENSE"),
    ("nanopb", "nanopb-LICENSE"),
  ]

  /// 辞書・例文データの出典。CC BY / CC BY-SA は帰属表示が義務(docs/design.md「ライセンス・レビュー」)。
  ///
  /// 見出しは出典名だけにする(どの言語でも通じる固有名)。全文ではなく出典・ライセンス名・原文への
  /// リンクを載せる(CC のライセンス表示要件はこれで満たせる)。本文は Flutter 版と同じ。
  static let dataSources: [LicenseEntry] = [
    LicenseEntry(
      packages: ["Wiktionary / kaikki.org"],
      text: """
        This app uses dictionary data extracted from the English Wiktionary by the Wiktextract project, \
        distributed at kaikki.org.

        Wiktionary content is licensed under the Creative Commons Attribution-ShareAlike 4.0 International \
        License (CC BY-SA 4.0) and the GNU Free Documentation License (GFDL).

        https://en.wiktionary.org/
        https://creativecommons.org/licenses/by-sa/4.0/

        Extraction: Tatu Ylonen, "Wiktextract: Wiktionary as Machine-Readable Structured Data", \
        Proceedings of the 13th Conference on Language Resources and Evaluation (LREC), pp. 1317-1325, \
        Marseille, 2022.
        https://kaikki.org/
        """),
    LicenseEntry(
      packages: ["Tatoeba"],
      text: """
        Sentences are from Tatoeba (https://tatoeba.org), released under CC-BY 2.0 FR.

        https://creativecommons.org/licenses/by/2.0/fr/
        """),
    LicenseEntry(
      packages: ["EJDict-hand"],
      text: """
        This app bundles the EJDict-hand English-Japanese dictionary data, released into the public domain \
        under CC0 1.0 Universal.

        https://github.com/kujirahand/EJDict
        https://creativecommons.org/publicdomain/zero/1.0/
        """),
    LicenseEntry(
      packages: ["Google Translate"],
      text: """
        Pronunciation is checked by opening Google Translate in the system browser. No Google API is called \
        from within this app.

        https://translate.google.com/
        """),
  ]

  /// 同梱のファイルを読めないとき。
  struct LoadError: Error {
    let resource: String
  }

  /// 一覧を組み立てる。同梱のライセンス本文を 1 つでも読めなければ失敗にする(欠けた一覧を出さない)。
  static func load(bundle: Bundle = .main) throws -> [LicenseItem] {
    func read(_ resource: String) throws -> String {
      guard let url = bundle.url(forResource: resource, withExtension: "txt"),
        let text = try? String(contentsOf: url, encoding: .utf8)
      else { throw LoadError(resource: resource) }
      return text
    }
    let bundled = try (fonts + packages).map { name, resource in
      LicenseEntry(packages: [name], text: try read(resource))
    }
    return group(dataSources + bundled)
  }

  /// ライセンスの本文から種別を判別する。判別できなければ nil(表示側が件数表記にする)。
  /// 当てにいきすぎず、主要なものだけを見る。
  static func detectLicenseName(_ text: String) -> String? {
    let head = text.count > 1200 ? String(text.prefix(1200)) : text
    let normalized = head.lowercased().replacing(/\s+/, with: " ")
    let patterns = [
      ("permission is hereby granted, free of charge", "MIT License"),
      ("redistribution and use in source and binary forms", "BSD License"),
      ("apache license", "Apache License 2.0"),
      ("sil open font license", "SIL Open Font License 1.1"),
      ("mozilla public license", "Mozilla Public License 2.0"),
      ("gnu general public license", "GNU General Public License"),
      ("gnu lesser general public license", "GNU Lesser General Public License"),
      ("cc0 1.0 universal", "CC0 1.0 Universal"),
      ("creative commons attribution-sharealike 4.0", "CC BY-SA 4.0"),
      ("cc-by 2.0 fr", "CC BY 2.0 FR"),
    ]
    return patterns.first { normalized.contains($0.0) }?.1
  }

  /// エントリを名前ごとにまとめる。1 エントリが複数に紐づくときは全部に配る。並びは名前順(大文字小文字を無視)。
  static func group(_ entries: [LicenseEntry]) -> [LicenseItem] {
    var names: [String] = []
    var texts: [String: [String]] = [:]
    for entry in entries {
      // Flutter 版と同じく、段落に組み直して空行 1 つで区切る(段落の中の改行は空白になる)。
      // CRLF の本文(Andika)は段落の中に \r が残る。Flutter はそれを空白として描くが、SwiftUI は改行にするので空白に置き換える。
      let text = paragraphs(of: entry.text)
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\r", with: " ") }
        .joined(separator: "\n\n")
        .trimmingCharacters(in: .whitespacesAndNewlines)
      guard !text.isEmpty else { continue }
      for name in entry.packages {
        if texts[name] == nil { names.append(name) }
        texts[name, default: []].append(text)
      }
    }
    return names
      .map { name in LicenseItem(name: name, summary: summary(of: texts[name]!), texts: texts[name]!) }
      .sorted { $0.name.lowercased() < $1.name.lowercased() }
  }

  /// ライセンスの本文を段落に分ける(Flutter の LicenseEntryWithLineBreaks.paragraphs の写し)。
  ///
  /// 段落の中の改行は空白でつなぐ。空行・改ページで段落を切り、前の行より字下げが深い行からも新しい段落にする
  /// (箇条書きの各項目を別の段落にするため)。字下げの深さは Flutter 版も表示に使わないので捨てる。
  /// 文字は Dart の文字列と同じく 1 文字ずつ見る(Swift の Character は \r\n を 1 文字にまとめるため、Unicode スカラーで見る)。
  static func paragraphs(of text: String) -> [String] {
    let scalars = Array(text.unicodeScalars)
    func substring(_ start: Int, _ end: Int) -> String {
      var view = String.UnicodeScalarView()
      view.append(contentsOf: scalars[start..<end])
      return String(view)
    }
    var lineStart = 0
    var position = 0
    var lastLineIndent = 0
    var currentLineIndent = 0
    var inParagraph = false
    var lines: [String] = []
    var result: [String] = []
    func flush() {
      result.append(lines.joined(separator: " "))
      lines.removeAll()
    }
    while position < scalars.count {
      let char = scalars[position]
      if !inParagraph {
        switch char {
        case " ":
          lineStart = position + 1
          currentLineIndent += 1
        case "\t":
          lineStart = position + 1
          currentLineIndent += 8
        case "\r", "\n", "\u{0C}":
          if !lines.isEmpty { flush() }
          if char == "\r" && position < scalars.count - 1 && scalars[position + 1] == "\n" {
            position += 1
          }
          lastLineIndent = 0
          currentLineIndent = 0
          lineStart = position + 1
        default:
          // LGPL 2.1 の「[this is a / single paragraph]」を 1 段落にするための、Flutter 版の決め打ち。
          if char == "[" { currentLineIndent += 1 }
          if !lines.isEmpty && currentLineIndent > lastLineIndent { flush() }
          inParagraph = true
        }
      } else {
        switch char {
        case "\n":
          lines.append(substring(lineStart, position))
          lastLineIndent = currentLineIndent
          currentLineIndent = 0
          lineStart = position + 1
          inParagraph = false
        case "\u{0C}":
          lines.append(substring(lineStart, position))
          flush()
          lastLineIndent = 0
          currentLineIndent = 0
          lineStart = position + 1
          inParagraph = false
        default:
          break
        }
      }
      position += 1
    }
    if inParagraph {
      lines.append(substring(lineStart, position))
      flush()
    } else if !lines.isEmpty {
      flush()
    }
    return result
  }

  /// 判別できた種別が 1 つに定まればその名前。判別できない本文が 1 つでも混ざれば nil。
  private static func summary(of texts: [String]) -> String? {
    let names = Set(texts.map(detectLicenseName))
    return names.count == 1 ? names.first! : nil
  }
}
