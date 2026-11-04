import EitangochoData
import EitangochoWordInfo
import Foundation

// 単語リストの各語を、アプリと同じ取得経路(DictionaryWordInfoProvider)で
// 日本語・繁体字それぞれ引き、項目ごとの値と出どころを JSON に書き出す。
//
// 使い方(tool/dictgen で): swift run dictgen-collect <単語リスト> <出力 JSON>
// 単語リストは 1 行 1 語。空行と `#` で始まる行は読み飛ばす。

/// 1 言語ぶんの取得結果。値が取れなかった項目は空文字。
struct CollectedLanguage: Encodable {
  /// provider が nil(辞書にも例文にも何も無い = 未収録)を返したか
  var notFound: Bool
  var ipa: String
  var partsOfSpeech: [String]
  var meaning: String
  /// `ejdict` / `kaikki`。訳が空なら空文字
  var meaningSource: String
  var exampleEn: String
  var exampleTranslation: String
  /// `tatoeba` / `kaikki`。例文が空なら空文字
  var exampleSource: String
  var exampleWordCount: Int
}

struct CollectedWord: Encodable {
  var word: String
  var ja: CollectedLanguage
  var zhHant: CollectedLanguage
}

let arguments = CommandLine.arguments
guard arguments.count == 3 else {
  FileHandle.standardError.write(Data("usage: dictgen-collect <words.txt> <out.json>\n".utf8))
  exit(64)
}
let wordsURL = URL(fileURLWithPath: arguments[1])
let outputURL = URL(fileURLWithPath: arguments[2])

// EJDict はアプリに同梱しているものと同じファイルを、リポジトリから直接読む。
let repositoryRoot = URL(fileURLWithPath: #filePath)
  .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
  .deletingLastPathComponent().deletingLastPathComponent()
let ejdictSource = repositoryRoot.appending(path: "assets/ejdict/ejdict-hand-utf8.txt")

// DB は出力と同じ場所のファイルに置く。EJDict の取り込みと kaikki のキャッシュを
// 再実行のたびにやり直さないため(Tatoeba はアプリと同じくキャッシュしない)。
try FileManager.default.createDirectory(
  at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
let database = try AppDatabase.open(at: outputURL.deletingLastPathComponent().appending(path: "cache.sqlite"))
try await EjdictImporter.importIfNeeded(dao: database.ejdictDao, source: ejdictSource)

let session = URLSession(configuration: .default)

func makeProvider(_ language: TranslationLanguage) -> DictionaryWordInfoProvider {
  DictionaryWordInfoProvider(
    kaikkiClient: KaikkiClient(session: session),
    tatoebaClient: TatoebaClient(session: session),
    deeplClient: DeeplClient(session: session),
    cacheDao: database.dictionaryCacheDao,
    ejdictDao: database.ejdictDao,
    ensureEjdictImported: {},
    // DeepL はアプリでも設定 UI を隠していて、ほぼ全員がキー未設定のため使わない
    getDeeplApiKey: { "" },
    getTranslationLanguage: { language }
  )
}

/// provider は出どころを返さないので、ここで判定する。
/// - 訳: 日本語は EJDict を優先し、未収録のときだけ kaikki に落ちる
/// - 例文: Tatoeba は訳の付いた文しか返さない(DeepL も使わない)ので、訳が空なら kaikki
func collect(_ word: String, _ language: TranslationLanguage) async throws -> CollectedLanguage {
  let info = try await makeProvider(language).fetch(word)
  let normalized = word.lowercased()
  let ejdictMeaning = language == .ja ? try await database.ejdictDao.lookup(normalized) : nil
  let meaning = info?.meaning ?? ""
  let exampleEn = info?.exampleEn ?? ""
  let exampleTranslation = info?.exampleTranslation ?? ""
  return CollectedLanguage(
    notFound: info == nil,
    ipa: info?.ipa ?? "",
    partsOfSpeech: info?.partsOfSpeech.map { "\($0)" } ?? [],
    meaning: meaning,
    meaningSource: meaning.isEmpty ? "" : (meaning == ejdictMeaning ? "ejdict" : "kaikki"),
    exampleEn: exampleEn,
    exampleTranslation: exampleTranslation,
    exampleSource: exampleEn.isEmpty ? "" : (exampleTranslation.isEmpty ? "kaikki" : "tatoeba"),
    exampleWordCount: exampleEn.split(whereSeparator: \.isWhitespace).count
  )
}

let words = try String(contentsOf: wordsURL, encoding: .utf8)
  .split(whereSeparator: \.isNewline)
  .map { $0.trimmingCharacters(in: .whitespaces) }
  .filter { !$0.isEmpty && !$0.hasPrefix("#") }

var results: [CollectedWord] = []
for (index, word) in words.enumerated() {
  let ja = try await collect(word, .ja)
  // Tatoeba への負荷を抑えるため、リクエストの間を空ける
  try await Task.sleep(for: .milliseconds(500))
  let zhHant = try await collect(word, .zhHant)
  try await Task.sleep(for: .milliseconds(500))
  results.append(CollectedWord(word: word, ja: ja, zhHant: zhHant))
  print("[\(index + 1)/\(words.count)] \(word)")
}

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
try encoder.encode(results).write(to: outputURL)
print("wrote \(results.count) words to \(outputURL.path)")
