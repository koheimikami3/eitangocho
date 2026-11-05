import EitangochoData
import EitangochoWordInfo
import Foundation

// 単語リストの各語を、アプリと同じ取得経路(DictionaryWordInfoProvider)で
// 日本語・繁体字それぞれ引き、項目ごとの値と出どころを JSON に書き出す。
//
// 使い方(tool/dictgen で): swift run dictgen-collect <単語リスト> <出力ディレクトリ>
// 単語リストは 1 行 1 語。空行と `#` で始まる行は読み飛ばす。
//
// 出力は chunkSize 語ずつの `input-001.json`, `input-002.json`, … で、そのまま生成(LLM)の
// 1 回分の入力になる。数千語だと数時間かかるため、ファイルごとに書き終えて保存し、
// 既にあるファイルの分は飛ばす(止まっても再実行で続きから集められる)。

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
  FileHandle.standardError.write(Data("usage: dictgen-collect <words.txt> <out-dir>\n".utf8))
  exit(64)
}
let wordsURL = URL(fileURLWithPath: arguments[1])
let outputDirectory = URL(fileURLWithPath: arguments[2], isDirectory: true)

/// 1 ファイルの語数。生成 1 回分として、出力が長くなりすぎず崩れにくい大きさ(試作で 50 語を確かめた)。
let chunkSize = 50

// EJDict はアプリに同梱しているものと同じファイルを、リポジトリから直接読む。
let repositoryRoot = URL(fileURLWithPath: #filePath)
  .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
  .deletingLastPathComponent().deletingLastPathComponent()
let ejdictSource = repositoryRoot.appending(path: "assets/ejdict/ejdict-hand-utf8.txt")

// DB は出力と同じ場所のファイルに置く。EJDict の取り込みと kaikki のキャッシュを
// 再実行のたびにやり直さないため(Tatoeba はアプリと同じくキャッシュしない)。
try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
let database = try AppDatabase.open(at: outputDirectory.appending(path: "cache.sqlite"))
try await EjdictImporter.importIfNeeded(dao: database.ejdictDao, source: ejdictSource)

let session = URLSession(configuration: .default)

// 同梱の事前生成辞書は空にする。辞書に足す語を元の取得経路の値から作るため、辞書の値を返す手順と
// 活用形を辞書の原形に寄せる手順(DictionaryWordInfoProvider.fetch の 0 と 1.5)を通さない。
let emptyPrebuiltDictionary = PrebuiltDictionary { Data(#"{"version":1,"words":{}}"#.utf8) }

func makeProvider(_ language: TranslationLanguage) -> DictionaryWordInfoProvider {
  DictionaryWordInfoProvider(
    prebuiltDictionary: emptyPrebuiltDictionary,
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

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]

let chunkCount = (words.count + chunkSize - 1) / chunkSize
for chunkIndex in 0..<chunkCount {
  let chunkURL = outputDirectory.appending(path: String(format: "input-%03d.json", chunkIndex + 1))
  if FileManager.default.fileExists(atPath: chunkURL.path) {
    print("skip \(chunkURL.lastPathComponent) (already collected)")
    continue
  }
  let chunk = words[(chunkIndex * chunkSize)..<min((chunkIndex + 1) * chunkSize, words.count)]
  var results: [CollectedWord] = []
  for word in chunk {
    let ja = try await collect(word, .ja)
    // Tatoeba への負荷を抑えるため、リクエストの間を空ける
    try await Task.sleep(for: .milliseconds(500))
    let zhHant = try await collect(word, .zhHant)
    try await Task.sleep(for: .milliseconds(500))
    results.append(CollectedWord(word: word, ja: ja, zhHant: zhHant))
  }
  // 書きかけのファイルを残さないよう、まとめて atomic に書く(途中で止まっても次回はこのファイルからやり直す)
  try encoder.encode(results).write(to: chunkURL, options: .atomic)
  print("[\(chunkIndex + 1)/\(chunkCount)] wrote \(chunkURL.lastPathComponent) (\(results.count) words)")
}
print("done: \(words.count) words in \(chunkCount) files under \(outputDirectory.path)")
