import EitangochoData
import EitangochoWordInfo
import Foundation
import Observation

/// 単語登録の 2 ステップ(英単語の入力 → 自動入力 → 確認フォーム)。
/// Flutter 版の WordRegistrationNotifier / WordRegistrationState と、画面が持っていた入力欄の値。
///
/// 画面を離れたら破棄する(登録の画面に戻ると最初のステップから始まる)。
@Observable
final class WordRegistrationModel {
  enum Step: Sendable {
    /// ステップ 1: 英単語の入力(自動入力 or 手動へスキップ)
    case input
    /// 辞書データ取得中
    case loading
    /// ステップ 2: 確認・修正フォーム
    case form
  }

  /// 入力を止めるエラーの種類。文言は表示の側で組み立てる。
  enum RegistrationError: Equatable, Sendable {
    /// 既に登録済み。word は登録済みの表記(大文字小文字は保存されたまま)。
    case duplicate(String)
    /// 英単語が空。
    case emptyWord
    /// 辞書の取得に失敗した(通信など)。
    case fetchFailed
    /// 必須項目(英単語・訳)が空。
    case requiredFields
  }

  /// 確認フォームの上部に出す警告の種類(自動入力で埋まらなかった項目を伝える)。
  enum Notice: Equatable, Sendable {
    /// 辞書に見つからなかった(全項目を手入力)。
    case notFound
    /// 訳だけ見つからなかった。
    case meaningNotFound
    /// 訳だけ見つかり、発音記号・例文が見つからなかった。
    case onlyMeaningFound
  }

  /// 自動入力のバッジを出す欄。
  enum Field: Sendable {
    case ipa, meaning, partsOfSpeech, exampleEn, exampleTranslation
  }

  private(set) var step: Step = .input
  /// 自動入力の取得結果。手動入力(スキップ・未収録)のときは nil。
  /// audioUrl はフォームに出さず、保存時にここから words へ書き込む。
  private(set) var fetched: WordInfo?
  /// 自動入力したが辞書に未収録だった
  private(set) var notFound = false
  /// 英例文はあるのに訳が取れなかった(訳は空のまま続行し警告を出す)
  private(set) var translationFailed = false
  private(set) var selectedPartsOfSpeech: Set<PartOfSpeech> = []
  private(set) var error: RegistrationError?
  /// 直前に登録した単語。ステップ 1 に「登録しました」と出すために持つ。
  /// 次の単語の取得・手動入力に進んだら消す。
  private(set) var registeredWord: String?

  // 入力欄の値。英単語はステップ 1 とフォームで共有する。
  var word = ""
  var ipa = "" { didSet { clearBadgeIfEmpty(.ipa, ipa) } }
  var meaning = "" { didSet { clearBadgeIfEmpty(.meaning, meaning) } }
  var exampleEn = "" { didSet { clearBadgeIfEmpty(.exampleEn, exampleEn) } }
  var exampleTranslation = "" { didSet { clearBadgeIfEmpty(.exampleTranslation, exampleTranslation) } }

  /// 「自動入力」バッジを出している欄。取得結果で埋めたときに立て、その欄を空にしたら消す。
  private(set) var autoFilledFields: Set<Field> = []

  /// 自動入力の取得・保存の途中か。連打(ボタンと Enter の重ね押しを含む)で 2 回目が
  /// 1 回目の重複の確認を待っている間に通ると、同じ単語が 2 件登録されるので止める。
  @ObservationIgnored private var busy = false

  @ObservationIgnored private let dao: WordDao
  @ObservationIgnored private let wordInfo: any WordInfoProvider
  @ObservationIgnored private let analytics: AnalyticsLogger
  @ObservationIgnored private let review: ReviewPrompter
  @ObservationIgnored private let currentLanguage: () -> TranslationLanguage

  init(
    dao: WordDao, wordInfo: any WordInfoProvider, analytics: AnalyticsLogger, review: ReviewPrompter,
    currentLanguage: @escaping () -> TranslationLanguage
  ) {
    self.dao = dao
    self.wordInfo = wordInfo
    self.analytics = analytics
    self.review = review
    self.currentLanguage = currentLanguage
  }

  /// 確認フォームの上部に出す警告(無ければ nil)。
  var notice: Notice? {
    if notFound { return .notFound }
    guard let fetched else { return nil }
    // 訳は必須項目なので、空なら他に何が埋まっていてもまずこれを伝える。
    // EJDict は句動詞を 1 件も収録していないため、句動詞ではこれが常態になる。
    if fetched.meaning.isEmpty { return .meaningNotFound }
    // audioUrl は画面に出さないので、文言どおり IPA と例文だけで判定する。
    if fetched.ipa.isEmpty && fetched.exampleEn.isEmpty { return .onlyMeaningFound }
    return nil
  }

  /// 品詞のバッジは「選択が 0 件になったら消す」。
  func showsBadge(_ field: Field) -> Bool {
    guard autoFilledFields.contains(field) else { return false }
    return field != .partsOfSpeech || !selectedPartsOfSpeech.isEmpty
  }

  /// ステップ 1 の「自動入力」。取得成功・未収録ならフォームへ、失敗ならステップ 1 に戻す。
  func autoFill() async {
    guard !busy else { return }
    let headword = normalizeHeadword(word)
    guard !headword.isEmpty else {
      error = .emptyWord
      return
    }
    busy = true
    defer { busy = false }
    // 辞書を引く前に重複を弾く(登録できない単語のために通信しない)。
    if await rejectIfDuplicate(headword) { return }
    step = .loading
    error = nil
    registeredWord = nil
    // 句(空白を含む見出し語)は辞書の収録が薄いので、取得率を分けて見る。
    let isPhrase = headword.contains(" ")
    do {
      guard let info = try await wordInfo.fetch(headword) else {
        notFound = true
        enterForm(with: nil)
        analytics.logAutofillResult(.notFound, isPhrase: isPhrase)
        return
      }
      // 抽象は翻訳の失敗を返せないため、「英例文はあるのに訳が空」を失敗とみなす
      // (取得成功で空になることは実質ない)。辞書側(kaikki)の例文を採ったときは
      // 対訳が無いのでここに該当する。例文の訳を持たない言語(英語の語義)では空が正常。
      notFound = false
      selectedPartsOfSpeech = Set(info.partsOfSpeech)
      translationFailed = info.translationLanguage.translatesExamples && !info.exampleEn.isEmpty && info.exampleTranslation.isEmpty
      enterForm(with: info)
      analytics.logAutofillResult(.success, isPhrase: isPhrase, notice: notice)
    } catch {
      step = .input
      self.error = .fetchFailed
      analytics.logAutofillResult(.fetchFailed, isPhrase: isPhrase)
    }
  }

  /// ステップ 1 の「スキップして手動で入力する」(空のフォームへ)。
  func skipToManual() {
    notFound = false
    translationFailed = false
    error = nil
    registeredWord = nil
    enterForm(with: nil)
  }

  /// フォームの「戻る」(ステップ 1 へ。取得結果は破棄する)。
  func backToInput() {
    step = .input
    fetched = nil
    notFound = false
    translationFailed = false
    error = nil
    selectedPartsOfSpeech = []
    clearFormFields()
  }

  func togglePartOfSpeech(_ pos: PartOfSpeech) {
    if selectedPartsOfSpeech.contains(pos) { selectedPartsOfSpeech.remove(pos) } else { selectedPartsOfSpeech.insert(pos) }
    error = nil
  }

  /// 保存する。保存できたら最初のステップへ戻す(macOS は登録後も登録の画面に留まり、
  /// 続けて次の単語を登録できるようにするため)。
  @discardableResult
  func save() async -> Bool {
    guard !busy else { return false }
    let headword = normalizeHeadword(word)
    let trimmedMeaning = meaning.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !headword.isEmpty, !trimmedMeaning.isEmpty else {
      error = .requiredFields
      return false
    }
    busy = true
    defer { busy = false }
    // フォームでも英単語を書き換えられるため、保存時にも重複を見る
    // (ステップ 1 で弾いた単語に戻された場合もここで止まる)。
    if await rejectIfDuplicate(headword) { return false }

    // 自動入力した言語。手動入力なら今の訳の言語で書いたとみなす。
    let language = fetched?.translationLanguage ?? currentLanguage()
    // 自動取得できた並び(辞書の主用法が先頭)を保ち、手動で足した品詞は規定の順で後ろに置く。
    let partsOfSpeech =
      selectedPartsOfSpeech.isEmpty
      ? [PartOfSpeech.other] : selectedPartsOfSpeech.ordered(basedOn: fetched?.partsOfSpeech ?? [])
    do {
      try await dao.insertWord(
        NewWord(
          word: headword,
          meaning: trimmedMeaning,
          ipa: ipa.trimmingCharacters(in: .whitespacesAndNewlines),
          partsOfSpeech: partsOfSpeech,
          exampleEn: exampleEn.trimmingCharacters(in: .whitespacesAndNewlines),
          exampleTranslation: exampleTranslation.trimmingCharacters(in: .whitespacesAndNewlines),
          translationLanguage: language.storageCode,
          // audioUrl はフォームに出さない。今の辞書は音声の URL を返さないため常に空になるが、
          // 経路だけ残している(docs/design.md)。
          audioUrl: fetched?.audioUrl ?? ""
        ))
    } catch {
      return false
    }
    // 自動入力の値をどの項目で書き換えたか(自動入力の品質の指標)。
    // フォームには取得値がそのまま入るので、保存値(trim 後)と比べる。
    let trim = { (value: String) in value.trimmingCharacters(in: .whitespacesAndNewlines) }
    analytics.logWordRegistered(
      autoFilled: fetched != nil,
      editedMeaning: fetched.map { trim($0.meaning) != trimmedMeaning } ?? false,
      editedExample: fetched.map { trim($0.exampleEn) != trim(exampleEn) } ?? false,
      editedIpa: fetched.map { trim($0.ipa) != trim(ipa) } ?? false)
    // 登録単語数の節目でのレビュー依頼(条件は ReviewPrompter が判定する)。依頼は
    // ReviewConfig.promptDelay だけ待ってから出る。成否は登録に関係しないので待たない。
    Task { [review] in await review.onWordRegistered() }
    reset()
    registeredWord = headword
    return true
  }

  /// 最初の状態(ステップ 1)へ戻す。
  private func reset() {
    backToInput()
    word = ""
    registeredWord = nil
  }

  /// 既に登録済みの単語なら、エラーを立てて true を返す。
  /// 単語帳として同じ単語が 2 件並ぶのは事故なので、登録させずに止める。
  private func rejectIfDuplicate(_ headword: String) async -> Bool {
    guard let existing = try? await dao.findByWord(headword) else { return false }
    error = .duplicate(existing.word)
    return true
  }

  /// フォームへ進み、取得結果を入力欄に入れる(英単語はステップ 1 の値をそのまま残す)。
  private func enterForm(with info: WordInfo?) {
    fetched = info
    step = .form
    guard let info else {
      clearFormFields()
      return
    }
    word = info.word
    ipa = info.ipa
    meaning = info.meaning
    exampleEn = info.exampleEn
    exampleTranslation = info.exampleTranslation
    var fields: Set<Field> = []
    if !info.ipa.isEmpty { fields.insert(.ipa) }
    if !info.meaning.isEmpty { fields.insert(.meaning) }
    if !info.partsOfSpeech.isEmpty { fields.insert(.partsOfSpeech) }
    if !info.exampleEn.isEmpty { fields.insert(.exampleEn) }
    if !info.exampleTranslation.isEmpty { fields.insert(.exampleTranslation) }
    autoFilledFields = fields
  }

  private func clearFormFields() {
    ipa = ""
    meaning = ""
    exampleEn = ""
    exampleTranslation = ""
    autoFilledFields = []
  }

  private func clearBadgeIfEmpty(_ field: Field, _ value: String) {
    if value.isEmpty { autoFilledFields.remove(field) }
  }
}
