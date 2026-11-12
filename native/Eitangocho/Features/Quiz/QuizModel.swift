import EitangochoData
import Foundation
import Observation
import OSLog

/// クイズで受け付けるキー(Flutter 版の QuizView の CallbackShortcuts)。
enum QuizKey: Sendable {
  case space, enter, numpadEnter, leftArrow, rightArrow, digit1, digit2
}

/// フラッシュクイズの進行(Flutter 版の QuizPageNotifier と QuizPageState)。
///
/// アプリが生きている間 1 つを持ち続け、回をほかの画面への切り替えをまたいで保つ。
/// iOS で、解き終えたときに出すインタースティシャルをタブを移ってやり直すことで避けられないようにするため
/// (2026-11-01 のユーザーの判断)。回が無いときはクイズの入口(`.entrance`)を出し、出題元・問題数を選んで
/// `start(source:count:trigger:)` で始める(2.18.0)。
///
/// macOS も 2.18.0 から同じ動きにした。それまではクイズの画面に入るたびに学習済みから 10 問を始め直し、
/// 画面を離れると回を捨てていた(Flutter 版の名残。答えは 1 問ごとに記録済みなので、保っても困らない)。
@Observable
final class QuizModel {
  /// セッションの局面。
  enum Phase: Sendable {
    /// 出題元・問題数を選ぶ入口。
    case entrance
    case active, done
  }

  /// 出題中・結果の回が何を出しているか。
  enum Round: Equatable, Sendable {
    /// 出題元から選んだ回。
    case source(QuizSource, QuizQuestionCount)
    /// 結果の「忘れた単語だけもう一度」の回。
    case retry
  }

  private(set) var phase: Phase = .entrance

  /// 回を始めたときに出題元から選んだ出題(selectQuizQuestions)のスナップショット。
  /// 回の途中の学習済みなどの変更は進行に影響させない。ほかの画面から戻ってきたときだけ、
  /// 残りの出題へ削除・編集を反映する(`enterFromTab()`)。
  private(set) var questions: [Word] = []
  private(set) var index = 0
  private(set) var revealed = false
  private(set) var okCount = 0
  private(set) var forgotWords: [Word] = []

  /// 今の回が何を出しているか。入口のときは nil。
  private(set) var round: Round?

  /// 今の回が、どの単語もまだ一度も出題していない状態で始めた回か(初めてのクイズ)。
  /// 初めてのクイズでは全画面広告を出さない(最初の体験を広告で邪魔しないため。2026-11 のユーザーの判断)。
  private(set) var isFirstEverRound = false

  /// 「忘れた単語だけもう一度」の後の「続ける」で戻る、直前の出題元の回。
  @ObservationIgnored private var lastSourceRound: (QuizSource, QuizQuestionCount)?

  /// 回答を DB に書いている間か。キーの押しっぱなし(キーリピート)で同じ単語に
  /// 二重に答えないよう、書き終えて次の問題に進むまで次の回答を受け付けない。
  @ObservationIgnored private var answering = false

  /// 回ごとに変わる番号。回答の書き込み中に画面の移動・始め直しで回が変わったとき、
  /// 書き終えた回答で別の回を進めない(捨てた回を完了と数えない)ために持つ。
  @ObservationIgnored private var session = 0

  @ObservationIgnored private let dao: WordDao
  @ObservationIgnored private let analytics: AnalyticsLogger
  @ObservationIgnored private let review: ReviewPrompter
  @ObservationIgnored private let currentWords: () -> [Word]
  /// 入口で選んだ条件と「全部」の一巡の保存先。テストでは nil でよい(条件を覚えず、全部は毎回出題元の全体から選ぶ)。
  @ObservationIgnored private let settings: SettingsStore?

  private static let logger = Logger(subsystem: "com.kohei.mikami.eitangocho", category: "quiz")

  /// `currentWords` は今ある単語すべて。始めるたびに読んで出題元の単語を選び、ほかの画面から戻ってきたときにも
  /// 読んで残りの出題に削除・編集を反映する。
  init(
    dao: WordDao, analytics: AnalyticsLogger, review: ReviewPrompter, settings: SettingsStore? = nil,
    currentWords: @escaping () -> [Word]
  ) {
    self.settings = settings
    self.dao = dao
    self.analytics = analytics
    self.review = review
    self.currentWords = currentWords
  }

  /// 出題中の単語。
  var current: Word? { phase == .active ? questions[index] : nil }

  /// 出題中が回の最後の問題か(答えると結果になる)。
  var isOnLastQuestion: Bool { phase == .active && index + 1 >= questions.count }

  // MARK: - 入口

  /// 出題元が未保存のときの既定。学習済みがあれば学習済み(今までの利用者の出題元)、無ければ学習中
  /// (初めての人がクイズで空の画面に当たらないように)。
  static func defaultSource(_ words: [Word]) -> QuizSource {
    WordListing.learned(words).isEmpty ? .learning : .learned
  }

  /// 入口で選ばれている出題元。保存した出題元が Pro の項目で、今 Pro でなければ(返金など)既定に戻して見せる。
  /// 保存した値は消さない(買い直したら戻るように。テーマカラーと同じ考え方)。
  /// `proUnlocked` が nil(購入状態がまだ分からない)の間は保存した値のまま(Pro の人の条件を戻さないように)。
  func entranceSource(proUnlocked: Bool?) -> QuizSource {
    let words = currentWords()
    let saved = settings?.quizSource ?? Self.defaultSource(words)
    return saved.requiresPro && proUnlocked == false ? Self.defaultSource(words) : saved
  }

  /// 入口で選ばれている問題数。Pro の項目で今 Pro でなければ 10 問に戻して見せる(nil の間は保存した値のまま)。
  func entranceCount(proUnlocked: Bool?) -> QuizQuestionCount {
    let saved = settings?.quizQuestionCount ?? .ten
    return saved.requiresPro && proUnlocked == false ? .ten : saved
  }

  /// 出題元の単語の数。
  func wordCount(_ source: QuizSource) -> Int {
    source.words(from: currentWords()).count
  }

  /// 登録が 1 語でもあるか(入口で「単語を登録」を出すかの判定)。
  var hasAnyWords: Bool { !currentWords().isEmpty }

  /// 入口の開始ボタンに出す、実際に出せる問題数。
  func availableCount(source: QuizSource, count: QuizQuestionCount) -> Int {
    min(pool(source: source, count: count).words.count, count.limit)
  }

  /// 「全部」の一巡の進み具合(答えた数 / 出題元の語数)。一巡を始めていなければ nil。
  func cycleProgress(_ source: QuizSource) -> (done: Int, total: Int)? {
    guard let start = settings?.quizCycleStarts[source] else { return nil }
    let words = source.words(from: currentWords())
    return (words.count - words.count { Self.isCycleRemaining($0, since: start) }, words.count)
  }

  /// 今の回が「全部」で、その出題元を一巡し終えたか(結果に「一巡しました」を出す)。
  var completedCycle: Bool {
    guard phase == .done, case .source(let source, .all) = round, let progress = cycleProgress(source) else {
      return false
    }
    return progress.total > 0 && progress.done == progress.total
  }

  /// 出題元・問題数から、出題を選ぶ元の単語と「全部」の一巡を始め直すかを決める。
  /// 開始ボタンの数(`availableCount`)と実際の出題(`start(source:count:trigger:now:)`)を同じ判断にするため 1 か所に置く。
  /// 「全部」は一巡の残りから選び、残りが無ければ(一巡を終えたか、初めて)出題元の全体から一巡を始め直す。
  private func pool(source: QuizSource, count: QuizQuestionCount) -> (words: [Word], restartsCycle: Bool) {
    let words = source.words(from: currentWords())
    guard count == .all, let settings else { return (words, false) }
    guard let start = settings.quizCycleStarts[source] else { return (words, true) }
    let remaining = words.filter { Self.isCycleRemaining($0, since: start) }
    return remaining.isEmpty ? (words, true) : (remaining, false)
  }

  /// 一巡を始め直す日時。前回出題日は DB に秒(切り捨て)で入るので、境界も秒の頭に揃え、
  /// 始めたのと同じ秒のうちに答えた単語も新しい一巡で答えた数に入れる。
  /// ただし同じ秒に前の一巡の回答があれば(答え終えてすぐ始め直したとき)、次の秒からにして前の一巡の回答を数えない
  /// (そのときだけ同じ秒のうちの新しい回答は残りに数えられるが、両方が 1 秒に収まることはまず無い)。
  private static func cycleStart(now: Date, words: [Word]) -> Date {
    let second = Date(timeIntervalSince1970: now.timeIntervalSince1970.rounded(.down))
    let answeredThisSecond = words.contains { ($0.lastReviewedAt ?? .distantPast) >= second }
    return answeredThisSecond ? second.addingTimeInterval(1) : second
  }

  /// 「全部」の一巡でまだ答えていない単語か(前回出題日が一巡を始めた日時より前か、未出題)。
  private static func isCycleRemaining(_ word: Word, since start: Date) -> Bool {
    word.lastReviewedAt.map { $0 < start } ?? true
  }

  /// 入口で選んだ出題元・問題数で新しい回を始める(選び方は selectQuizQuestions)。選んだ条件は覚えておく。
  /// 直前に答えた単語は日時が新しくなって後ろに回るため、「続ける」では次の単語が出る。
  /// 「全部」は一巡の残りから 50 問を選び、残りが無ければ一巡を始め直す(`pool`)。
  /// `trigger` は計測用(どこから始めたか)。
  func start(source: QuizSource, count: QuizQuestionCount, trigger: QuizTrigger, now: Date = .now) {
    settings?.setQuizSource(source)
    settings?.setQuizQuestionCount(count)
    let pool = pool(source: source, count: count)
    if pool.restartsCycle { settings?.setQuizCycleStart(source, Self.cycleStart(now: now, words: pool.words)) }
    let questions = selectQuizQuestions(pool.words, count: count.limit)
    guard !questions.isEmpty else {
      showEntrance()
      return
    }
    begin(questions, round: .source(source, count), trigger: trigger)
    lastSourceRound = (source, count)
  }

  /// 結果の「忘れた単語だけもう一度」。直前の回で忘れた単語を、出題の選び方を通さずにそのまま出す
  /// (離れている間に削除された単語は外し、編集された単語は今の内容にする)。
  func retryForgotten() {
    let latest = latestWords()
    let questions = forgotWords.compactMap { latest[$0.id] }.shuffled()
    guard !questions.isEmpty else { return }
    begin(questions, round: .retry, trigger: .retry)
  }

  /// `questions` で新しい回を始めて記録する(出題元からの始め方とやり直しで共通)。
  private func begin(_ questions: [Word], round: Round, trigger: QuizTrigger) {
    // 初めてのクイズかは、回を始める前の状態で見る。
    let isFirst = currentWords().allSatisfy { $0.lastReviewedAt == nil }
    resetSession(questions, phase: .active)
    self.round = round
    isFirstEverRound = isFirst
    switch round {
    case .source(let source, let count):
      analytics.logQuizStarted(trigger: trigger, questions: questions, source: source, count: count)
    case .retry:
      analytics.logQuizStarted(trigger: trigger, questions: questions, source: nil, count: nil)
    }
  }

  /// 今ある単語を ID で引く表(離れている間の削除・編集を回の出題に反映するのに使う)。
  private func latestWords() -> [Int64: Word] {
    Dictionary(currentWords().map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
  }

  /// 結果の「続ける」。同じ出題元・問題数で次の回へ(やり直しの回の後は、その前の出題元の回へ)。
  /// やり直しの回は出題元の回の結果からしか始められないので、出題元の回が無いことは無いが、念のため入口に戻す。
  func continueRound() {
    if let (source, count) = lastSourceRound {
      start(source: source, count: count, trigger: .continued)
    } else {
      showEntrance()
    }
  }

  /// 入口に戻る(出題中の × と、結果の「条件を変える」)。答えは 1 問ごとに記録済みなので確認はしない。
  func showEntrance() {
    resetSession([], phase: .entrance)
  }

  /// クイズのタブ(macOS はサイドバー)から入ったとき(選んでいるものを押し直したときも)。
  ///
  /// 回が無ければ入口を出す。途中の回は続きから(離れている間の削除・編集を反映して)、
  /// 結果は結果のまま見せ、押し直してもやり直さない(やり直せると iOS のインタースティシャルを避けられるため)。
  func enterFromTab() {
    switch phase {
    case .entrance:
      showEntrance()
      // 入口で選ばれている出題元が空なら、今までの空の画面と同じく記録する(Pro かは問わず保存した値で見る)。
      let source = settings?.quizSource ?? Self.defaultSource(currentWords())
      if wordCount(source) == 0 { analytics.logQuizEmptyShown() }
    case .active: refreshRemainingQuestions()
    case .done: break
    }
  }

  /// 離れている間に削除された単語を残りの出題から外し、編集された単語は今の内容にする。
  /// 答え済みの単語(結果の「忘れていた単語」に出るもの)はそのまま残す。
  private func refreshRemainingQuestions() {
    let latest = latestWords()
    let currentID = questions[index].id
    let remaining = questions[index...].compactMap { latest[$0.id] }
    questions = Array(questions[..<index]) + remaining
    // 出題中の単語が消えたら、次の単語は開示前から見せる。
    if remaining.first?.id != currentID { revealed = false }
    guard remaining.isEmpty else { return }
    // 残りがすべて消えた。1 問も答えていなければ入口に戻し、答えていればそこまでで回を終える。
    if index == 0 {
      showEntrance()
    } else {
      finish()
    }
  }

  /// 回の状態を最初に戻し、`questions` を出題にする。
  private func resetSession(_ questions: [Word], phase: Phase) {
    session += 1
    self.questions = questions
    self.phase = phase
    index = 0
    revealed = false
    okCount = 0
    forgotWords = []
    round = nil
    isFirstEverRound = false
  }

  func reveal() {
    revealed = true
  }

  /// 「覚えている」: 実績を記録して次へ進む。
  func answerKnew() async {
    await answer(knew: true)
  }

  /// 「忘れていた」: 学習中に戻し、実績を記録して次へ進む。
  func answerForgot() async {
    await answer(knew: false)
  }

  /// キー操作。開示前は Space / Enter で答えを開き、開示後は ← / 1 で忘れていた、
  /// → / 2 で覚えている。受け付けたキーなら、その処理(回答は DB への書き込み)を返す。
  @discardableResult
  func handleKey(_ key: QuizKey) -> Task<Void, Never>? {
    guard phase == .active else { return nil }
    switch (revealed, key) {
    case (false, .space), (false, .enter), (false, .numpadEnter):
      reveal()
      return Task {}
    case (true, .leftArrow), (true, .digit1):
      return Task { await answerForgot() }
    case (true, .rightArrow), (true, .digit2):
      return Task { await answerKnew() }
    default:
      return nil
    }
  }

  private func answer(knew: Bool) async {
    guard let word = current, !answering else { return }
    answering = true
    defer { answering = false }
    let session = session
    do {
      if !knew {
        try await dao.setLearned(id: word.id, false)
      }
      try await dao.recordQuizResult(id: word.id, knew: knew)
    } catch {
      Self.logger.error("クイズの回答を記録できない: \(String(describing: error), privacy: .public)")
      return
    }
    // 書き込みの間に回が変わっていたら進めない(回答の記録は残す。答えたこと自体は事実なので)。
    guard session == self.session else { return }
    advance(knew: knew, word: word)
  }

  private func advance(knew: Bool, word: Word) {
    let next = index + 1
    index = next
    revealed = false
    if knew {
      okCount += 1
    } else {
      forgotWords.append(word)
    }
    if next >= questions.count {
      finish()
    }
  }

  /// 回を終えて結果にする。
  private func finish() {
    phase = .done
    analytics.logQuizCompleted(okCount: okCount, forgotCount: forgotWords.count)
    // 最後まで終えた直後がクイズでのレビュー依頼の契機(条件は ReviewPrompter が判定し、
    // 満たさなければ何も起きない)。依頼の成否はクイズの進行に関係しないので待たない。
    let (okCount, total) = (okCount, questions.count)
    Task { await review.onQuizCompleted(okCount: okCount, total: total) }
  }
}

extension QuizModel {
  /// 出題中の上に出す、何を出している回か(出題元と、全部なら一巡の進み具合)。両 OS で使う。
  var roundLabel: String {
    switch round {
    case .retry: return String(localized: .quizSourceForgotten)
    case .source(let source, let count):
      let name = String(localized: source.label)
      guard count == .all, let progress = cycleProgress(source) else { return name }
      return name + " · " + String(localized: .quizCycleProgress(progress.done, progress.total))
    case nil: return ""
    }
  }

  /// 結果に出す一巡の案内(全部の回だけ)。一巡し終えたら「一巡しました」、途中なら進み具合。
  var cycleNote: String? {
    guard case .source(let source, .all) = round else { return nil }
    if completedCycle { return String(localized: .quizCycleCompleted) }
    return cycleProgress(source).map { String(localized: .quizCycleProgress($0.done, $0.total)) }
  }
}
