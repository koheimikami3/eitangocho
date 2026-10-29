import EitangochoData
import Foundation

/// kaikki.org(wiktextract)のクライアント。
///
/// Wiktionary のダンプを構造化した静的 JSONL を配信しており、1 リクエストで
/// IPA・品詞・例文が揃う。API ではなくファイル配信なので、単語ごとに
/// `/dictionary/English/meaning/<頭文字>/<頭2文字>/<単語>.jsonl` を取りに行く。
public struct KaikkiClient: Sendable {
  private let session: URLSession

  public init(session: URLSession) {
    self.session = session
  }

  static let timeout: TimeInterval = 15

  /// 名乗らずに叩かない(商用サービスではないため)。
  static let userAgent = "eitangocho (https://github.com/koheimikami3/eitangocho)"

  /// 訳語のうち残す言語(kaikki の `lang_code`)。訳の言語のどれでも
  /// キャッシュから引けるよう、対応言語の分はすべて残す。
  static let keptLangCodes = Set(TranslationLanguage.allCases.compactMap(\.kaikkiLangCode))

  /// 正規化済みの JSON 配列文字列を返す(キャッシュにそのまま保存する形)。
  /// 未収録は nil、それ以外の失敗は WordInfoError。
  ///
  /// 生の JSONL は 1 語で 20〜170KB あるため、そのままはキャッシュしない。
  /// 使う項目だけに絞って詰め直す(apple で 168KB → 約 1KB)。
  public func fetchEntriesJson(_ word: String) async throws -> String? {
    let normalized = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard !normalized.isEmpty else { return nil }

    var body = try await get(normalized)
    // kaikki は大文字小文字を区別する。固有名詞・月名は見出しが大文字なので
    // (september は 404 で September は 200)、404 なら頭大文字で引き直す。
    if body == nil {
      body = try await get(normalized.prefix(1).uppercased() + normalized.dropFirst())
    }
    guard let body else { return nil }

    let entries = Self.parseJsonl(body)
    guard !entries.isEmpty else { return nil }
    let encoder = JSONEncoder()
    encoder.outputFormatting = .withoutEscapingSlashes
    let data = try encoder.encode(entries)
    return String(decoding: data, as: UTF8.self)
  }

  /// fetchEntriesJson が返した JSON 配列(またはキャッシュ)をパースする。
  public static func parseEntries(_ entriesJson: String) throws -> [KaikkiEntry] {
    do {
      return try JSONDecoder().decode([KaikkiEntry].self, from: Data(entriesJson.utf8))
    } catch {
      throw WordInfoError("kaikki のキャッシュ形式が想定外", cause: error)
    }
  }

  /// 1 パスを取得する。404 は nil、200 以外は WordInfoError。
  private func get(_ title: String) async throws -> String? {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "kaikki.org"
    components.path = "/dictionary/English/meaning/\(title.prefix(1))/\(title.prefix(2))/\(title).jsonl"
    var request = URLRequest(url: components.url!, timeoutInterval: Self.timeout)
    request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")

    let data: Data
    let status: Int
    do {
      (data, status) = try await HTTP.data(request, session: session)
    } catch {
      throw WordInfoError("kaikki の取得に失敗した", cause: error)
    }
    if status == 404 { return nil }
    guard status == 200 else { throw WordInfoError("kaikki がステータス \(status) を返した") }
    return String(decoding: data, as: UTF8.self)
  }

  /// JSONL(1 行 1 品詞)をパースし、使う項目だけに絞ったエントリにする。
  ///
  /// 例文は `type == "example"`(用例)だけ残し、`quotation`(出典付きの
  /// 文献引用)は捨てる。引用は長文で単語帳には使えないうえ、キャッシュサイズの
  /// 大半を占めるため。
  ///
  /// 訳語は訳の言語の分だけ残す。全言語ぶんを持っており(`give up` は
  /// 1 品詞に 243 件)、そのまま保存するとキャッシュを縮めた意味が無くなる。
  /// 北京語の訳語は normalizeLangCode で `cmn` に揃えてから絞る。
  ///
  /// 語義の文(`glosses`)とタグは残す。英語の語義(TranslationLanguage.enDefinition)に使うため。
  static func parseJsonl(_ body: String) -> [KaikkiEntry] {
    var entries: [KaikkiEntry] = []
    for line in body.split(whereSeparator: \.isNewline) {
      guard !line.allSatisfy(\.isWhitespace),
        // 1 行壊れていても他の品詞は使えるので、その行だけ捨てる
        var entry = try? JSONDecoder().decode(KaikkiEntry.self, from: Data(line.utf8))
      else { continue }
      entry.senses = entry.senses.map { sense in
        var sense = sense
        sense.examples = sense.examples.filter { $0.type == "example" }
        return sense
      }
      entry.translations = entry.translations.map(normalizeLangCode).filter {
        $0.langCode.map(keptLangCodes.contains) ?? false
      }
      entries.append(entry)
    }
    return entries
  }

  /// 北京語の訳語の `lang_code` を `cmn` に揃える。
  ///
  /// Wiktionary の訳語表は語によって北京語を `cmn` と書くもの(run・happy)と、
  /// `zh` + 言語名 `Chinese Mandarin` と書くもの(apple・dog・water)がある。
  /// 後者を拾わないと、基本語でも中国語の訳が空になる。`zh` には閩南語
  /// (Hokkien)や東干語(Dungan)も言語名 `Chinese` で混ざるため、`zh` を
  /// まるごと北京語として扱わず、言語名で見分ける。
  static func normalizeLangCode(_ translation: KaikkiTranslation) -> KaikkiTranslation {
    guard translation.langCode == "zh", translation.lang == "Chinese Mandarin" else { return translation }
    var normalized = translation
    normalized.langCode = "cmn"
    return normalized
  }
}
