#if DEBUG
  import EitangochoData
  import Foundation
  import Observation

  /// Dev ビルドの診断画面の状態。引き継ぎと混在同期を手で確かめるためだけに置く
  /// (本来の画面とは別のウィンドウで、メニューの「Debug」から開く)。
  @Observable
  final class DiagnosticsModel {
    /// Flutter 版が UserDefaults に置いている設定のキー(Swift 版も同じキーで読む)。
    static let preferenceKeys = [
      "quizDirection", "showIpa", "deeplApiKey", "uiScale", "appearance", "cardLayout",
      "wordSortOrder", "translationLanguage", "reviewQuizCompletedCount", "reviewLastRequestedAt",
      "syncEnabled", "syncLastSyncedAt",
    ]

    private(set) var words: [Word] = []
    private(set) var inspection: DatabaseInspection?
    /// 元ファイル(Flutter 版の DB)の今の状態。
    private(set) var source: DriftDatabaseImporter.SourceFileState?
    private(set) var errorMessage: String?

    let database: AppDatabase
    let sourceURL: URL

    init(database: AppDatabase, sourceURL: URL) {
      self.database = database
      self.sourceURL = sourceURL
    }

    /// 設定のキーごとの値の型(値そのものは出さない。DeepL のキーを含むため)。
    var preferenceTypes: [(key: String, type: String?)] {
      Self.preferenceKeys.map { key in
        (key, UserDefaults.standard.object(forKey: key).map(Self.typeName))
      }
    }

    /// 単語の一覧を見張り、変わるたびに件数なども読み直す。
    func observe() async {
      do {
        for try await words in database.wordDao.observeAll() {
          self.words = words
          await refresh()
        }
      } catch {
        errorMessage = String(describing: error)
      }
    }

    func refresh() async {
      do {
        inspection = try await database.inspect()
      } catch {
        errorMessage = String(describing: error)
      }
      source = DriftDatabaseImporter.sourceFileState(at: sourceURL)
    }

    // MARK: - 混在同期を確かめるための操作

    func addTestWord() async {
      await run {
        let stamp = Date.now.formatted(.iso8601.time(includingFractionalSeconds: false))
        try await database.wordDao.insertWord(NewWord(word: "swift-\(stamp)", meaning: "Swift 版で追加"))
      }
    }

    func editFirstWord() async {
      guard let word = words.first else { return }
      await run {
        try await database.wordDao.updateWord(
          id: word.id,
          WordEdit(
            word: word.word, meaning: word.meaning + "(Swift で編集)", ipa: word.ipa,
            partsOfSpeech: word.partsOfSpeech, exampleEn: word.exampleEn,
            exampleTranslation: word.exampleTranslation))
      }
    }

    func deleteFirstWord() async {
      guard let word = words.first else { return }
      await run { try await database.wordDao.deleteWord(id: word.id) }
    }

    private func run(_ body: () async throws -> Void) async {
      do {
        try await body()
        errorMessage = nil
      } catch {
        errorMessage = String(describing: error)
      }
    }

    private static func typeName(_ value: Any) -> String {
      if let number = value as? NSNumber {
        if CFGetTypeID(number) == CFBooleanGetTypeID() { return "Bool" }
        return CFNumberIsFloatType(number) ? "Double" : "Int"
      }
      if value is String { return "String" }
      return String(describing: type(of: value))
    }
  }
#endif
