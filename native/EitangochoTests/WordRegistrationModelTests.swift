import EitangochoData
import EitangochoWordInfo
import Foundation
import Testing

@testable import Eitangocho

/// Flutter 版の word_registration_notifier_test.dart と word_registration_state_test.dart を移したもの。
@MainActor
struct WordRegistrationModelTests {
  /// 自動入力のテスト用(実際の取得元を呼ばない)。
  private struct FakeWordInfoProvider: WordInfoProvider {
    let handler: @Sendable (String) async throws -> WordInfo?
    func fetch(_ word: String) async throws -> WordInfo? { try await handler(word) }
  }

  nonisolated private final class Box<T>: @unchecked Sendable {
    var value: T
    init(_ value: T) { self.value = value }
  }

  nonisolated private static let fetchedInfo = WordInfo(
    word: "serendipity", ipa: "/ˌsɛɹənˈdɪpɪti/", partsOfSpeech: [.noun], meaning: "思わぬ発見",
    exampleEn: "It was pure serendipity.", exampleTranslation: "まったくの偶然だった。",
    audioUrl: "https://example.com/a.mp3")

  private let database: AppDatabase
  private let analytics = FakeAnalyticsClient()

  init() throws {
    database = try AppDatabase.inMemory()
  }

  private func makeModel(
    language: TranslationLanguage = .ja, _ handler: @escaping @Sendable (String) async throws -> WordInfo? = { _ in nil }
  ) -> WordRegistrationModel {
    WordRegistrationModel(
      dao: database.wordDao, wordInfo: FakeWordInfoProvider(handler: handler), analytics: AnalyticsLogger(analytics),
      currentLanguage: { language })
  }

  private func fill(_ model: WordRegistrationModel, word: String, meaning: String, ipa: String = "", exampleEn: String = "") {
    model.word = word
    model.meaning = meaning
    model.ipa = ipa
    model.exampleEn = exampleEn
  }

  // MARK: - 保存

  @Test func 英単語が空だとエラーになり保存されない() async throws {
    let model = makeModel()
    fill(model, word: "  ", meaning: "りんご")
    #expect(await model.save() == false)
    #expect(model.error == .requiredFields)
    #expect(try await database.wordDao.getAll().isEmpty)
  }

  @Test func 訳が空だとエラーになり保存されない() async throws {
    let model = makeModel()
    fill(model, word: "apple", meaning: " ")
    #expect(await model.save() == false)
    #expect(model.error == .requiredFields)
  }

  @Test func 保存するとDAOにinsertされ最初のステップに戻る() async throws {
    let model = makeModel()
    fill(model, word: " apple ", meaning: " りんご ", ipa: "/ˈæpəl/", exampleEn: "An apple a day.")
    #expect(await model.save())
    let words = try await database.wordDao.getAll()
    #expect(words.map(\.word) == ["apple"])
    #expect(words.first?.meaning == "りんご")
    #expect(words.first?.exampleEn == "An apple a day.")
    #expect(words.first?.translationLanguage == "ja")
    #expect(model.step == .input)
    #expect(model.word.isEmpty)
    #expect(model.registeredWord == "apple")
  }

  @Test func 品詞を未選択のまま保存するとその他が補われる() async throws {
    let model = makeModel()
    fill(model, word: "apple", meaning: "りんご")
    await model.save()
    #expect(try await database.wordDao.getAll().first?.partsOfSpeech == [.other])
  }

  @Test func 手動で選んだ品詞はタップ順ではなく規定順で保存される() async throws {
    let model = makeModel()
    // 形容詞 → 名詞 の順に押す。
    model.togglePartOfSpeech(.adjective)
    model.togglePartOfSpeech(.noun)
    fill(model, word: "light", meaning: "光")
    await model.save()
    // 先頭の品詞でバッジ色が決まるため、押した順に引きずられないこと。
    #expect(try await database.wordDao.getAll().first?.partsOfSpeech == [.noun, .adjective])
  }

  @Test func 手動入力なら今の訳の言語で保存する() async throws {
    let model = makeModel(language: .zhHant)
    fill(model, word: "apple", meaning: "蘋果")
    await model.save()
    #expect(try await database.wordDao.getAll().first?.translationLanguage == "zh-Hant")
  }

  // MARK: - 自動入力

  @Test func 空入力はエラーを表示しinputに留まる() async {
    let model = makeModel()
    model.word = "  "
    await model.autoFill()
    #expect(model.step == .input)
    #expect(model.error == .emptyWord)
  }

  @Test func 成功するとformへ進み取得結果と品詞が入る() async {
    let model = makeModel { _ in Self.fetchedInfo }
    model.word = "serendipity"
    await model.autoFill()
    #expect(model.step == .form)
    #expect(model.fetched == Self.fetchedInfo)
    #expect(model.selectedPartsOfSpeech == [.noun])
    #expect(model.meaning == "思わぬ発見")
    #expect(model.showsBadge(.meaning))
    #expect(!model.translationFailed)
  }

  @Test func 未収録ならformへ進みnotFoundが立つ() async {
    let model = makeModel { _ in nil }
    model.word = "zzzzz"
    await model.autoFill()
    #expect(model.step == .form)
    #expect(model.notFound)
    #expect(model.notice == .notFound)
    // 英単語はステップ 1 の入力のまま残す。
    #expect(model.word == "zzzzz")
  }

  @Test func 取得に失敗したらinputに戻しエラーを表示する() async {
    let model = makeModel { _ in throw WordInfoError("offline") }
    model.word = "apple"
    await model.autoFill()
    #expect(model.step == .input)
    #expect(model.error == .fetchFailed)
  }

  // DeepL のキーは条件に含めない。辞書側の例文を採って訳が無い場合に警告を出すため。
  @Test func 英例文ありなのに訳が空ならtranslationFailed() async {
    var info = Self.fetchedInfo
    info.exampleTranslation = ""
    let fetched = info
    let model = makeModel { _ in fetched }
    model.word = "serendipity"
    await model.autoFill()
    #expect(model.translationFailed)
  }

  // 英語の語義は例文の訳を持たないので、空が正常。
  @Test func 英語の語義なら訳が空でもtranslationFailedは立たない() async {
    var info = Self.fetchedInfo
    info.exampleTranslation = ""
    info.translationLanguage = .enDefinition
    let fetched = info
    let model = makeModel { _ in fetched }
    model.word = "serendipity"
    await model.autoFill()
    #expect(!model.translationFailed)
  }

  @Test func 英例文が無ければtranslationFailedは立たない() async {
    var info = Self.fetchedInfo
    info.exampleEn = ""
    info.exampleTranslation = ""
    let fetched = info
    let model = makeModel { _ in fetched }
    model.word = "serendipity"
    await model.autoFill()
    #expect(!model.translationFailed)
  }

  @Test func 自動入力後に保存するとaudioUrlと取得した言語も書き込まれる() async throws {
    var info = Self.fetchedInfo
    info.translationLanguage = .fr
    let fetched = info
    let model = makeModel(language: .ja) { _ in fetched }
    model.word = "serendipity"
    await model.autoFill()
    await model.save()
    let saved = try await database.wordDao.getAll().first
    #expect(saved?.audioUrl == "https://example.com/a.mp3")
    #expect(saved?.translationLanguage == "fr")
  }

  @Test func 自動取得の品詞順は保たれ手動で足した品詞は後ろに付く() async throws {
    // 辞書は動詞を先に返す語(run など)を想定する。
    let model = makeModel { _ in WordInfo(word: "run", ipa: "/ɹʌn/", partsOfSpeech: [.verb, .noun], meaning: "走る") }
    model.word = "run"
    await model.autoFill()
    // 動詞を外して付け直し、形容詞を足す。
    model.togglePartOfSpeech(.verb)
    model.togglePartOfSpeech(.verb)
    model.togglePartOfSpeech(.adjective)
    await model.save()
    // 辞書の主用法(動詞)が先頭のままで、バッジは動詞色になる。
    #expect(try await database.wordDao.getAll().first?.partsOfSpeech == [.verb, .noun, .adjective])
  }

  @Test func backToInputで取得結果と品詞の選択と入力が破棄される() async {
    let model = makeModel { _ in Self.fetchedInfo }
    model.word = "serendipity"
    await model.autoFill()
    model.backToInput()
    #expect(model.step == .input)
    #expect(model.fetched == nil)
    #expect(model.selectedPartsOfSpeech.isEmpty)
    #expect(model.meaning.isEmpty)
    #expect(!model.showsBadge(.meaning))
  }

  @Test func skipToManualは取得結果なしでformへ進む() {
    let model = makeModel()
    model.skipToManual()
    #expect(model.step == .form)
    #expect(model.fetched == nil)
    #expect(!model.notFound)
    #expect(model.notice == nil)
  }

  @Test func 欄を空にすると自動入力のバッジが消える() async {
    let model = makeModel { _ in Self.fetchedInfo }
    model.word = "serendipity"
    await model.autoFill()
    model.ipa = ""
    #expect(!model.showsBadge(.ipa))
    // 打ち直してもバッジは戻らない(自動入力の値ではなくなったため)。
    model.ipa = "/x/"
    #expect(!model.showsBadge(.ipa))
    // 品詞は選択が 0 件になったら消す。
    model.togglePartOfSpeech(.noun)
    #expect(!model.showsBadge(.partsOfSpeech))
  }

  // MARK: - 重複登録

  private func insertApple() async throws {
    try await database.wordDao.insertWord(NewWord(word: "apple", meaning: "りんご"))
  }

  @Test func 登録済みならautoFillは辞書を引かずinputに留まる() async throws {
    try await insertApple()
    let called = Box(false)
    let model = makeModel { _ in
      called.value = true
      return nil
    }
    model.word = "apple"
    await model.autoFill()
    #expect(!called.value)
    #expect(model.step == .input)
    #expect(model.error == .duplicate("apple"))
  }

  @Test func 大文字違いと前後空白でもautoFillは弾く() async throws {
    try await insertApple()
    let model = makeModel()
    model.word = "  Apple "
    await model.autoFill()
    #expect(model.error == .duplicate("apple"))
  }

  @Test func saveも弾き単語は増えない() async throws {
    try await insertApple()
    let model = makeModel()
    fill(model, word: "Apple", meaning: "りんご")
    #expect(await model.save() == false)
    #expect(model.error == .duplicate("apple"))
    #expect(try await database.wordDao.getAll().count == 1)
  }

  // MARK: - 句動詞の空白の正規化

  @Test func autoFillは語間の連続空白を1つに畳んで辞書を引く() async {
    let requested = Box<String?>(nil)
    let model = makeModel { word in
      requested.value = word
      return nil
    }
    model.word = "  give   up "
    await model.autoFill()
    #expect(requested.value == "give up")
  }

  @Test func saveも畳んだ形で保存する() async throws {
    let model = makeModel()
    fill(model, word: "give   up", meaning: "あきらめる")
    await model.save()
    #expect(try await database.wordDao.getAll().first?.word == "give up")
  }

  // MARK: - 警告(word_registration_state_test)

  private func notice(_ info: WordInfo) async -> WordRegistrationModel.Notice? {
    let model = makeModel { _ in info }
    model.word = info.word
    await model.autoFill()
    return model.notice
  }

  @Test func 全部埋まっていれば警告を出さない() async {
    #expect(await notice(Self.fetchedInfo) == nil)
  }

  // EJDict は句動詞を 1 件も収録していないため、句動詞ではこれが常態になる。
  @Test func 訳が空なら他が埋まっていても訳の不足を先に伝える() async {
    var info = Self.fetchedInfo
    info.meaning = ""
    #expect(await notice(info) == .meaningNotFound)
  }

  @Test func 訳だけ取れたときはIPAと例文の不足を伝える() async {
    var info = Self.fetchedInfo
    info.ipa = ""
    info.exampleEn = ""
    #expect(await notice(info) == .onlyMeaningFound)
  }

  // MARK: - 計測

  nonisolated private static let phraseInfo = WordInfo(
    word: "give up", ipa: "/ɡɪv ʌp/", meaning: "あきらめる", exampleEn: "Never give up.")

  @Test func 自動入力の結果を送る_取得_未収録_失敗() async {
    let results = Box<[@Sendable () throws -> WordInfo?]>([
      { Self.phraseInfo }, { nil }, { throw WordInfoError("offline") },
    ])
    let model = makeModel { _ in try results.value.removeFirst()() }
    for word in ["give up", "zzzzz", "apple"] {
      model.word = word
      await model.autoFill()
      model.backToInput()
    }
    #expect(
      analytics.eventsNamed("autofill_result") == [
        ["result": "success", "notice": "none", "is_phrase": "true"],
        ["result": "not_found", "is_phrase": "false"],
        ["result": "fetch_failed", "is_phrase": "false"],
      ])
  }

  @Test func 自動入力の値から書き換えた項目を送る_前後の空白は書き換えとみなさない() async {
    let model = makeModel { _ in Self.phraseInfo }
    model.word = "give up"
    await model.autoFill()
    model.ipa = " /ɡɪv ʌp/ "
    model.meaning = "諦める"
    #expect(await model.save())
    #expect(
      analytics.eventsNamed("word_registered") == [
        ["method": "autofill", "edited_meaning": "true", "edited_example": "false", "edited_ipa": "false"]
      ])
  }

  @Test func 保存できなかったときは登録を送らない() async {
    let model = makeModel()
    fill(model, word: "apple", meaning: "")
    #expect(await model.save() == false)
    #expect(analytics.eventsNamed("word_registered").isEmpty)
  }
}
