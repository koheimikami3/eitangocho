import EitangochoData
import Foundation
import SwiftUI

/// アプリの外観(配色)。iOS・macOS 共通の設定。
///
/// rawValue は UserDefaults に保存する名前で、light / dark は Flutter 版の enum の name と同じ。
/// `system`(OS の設定に追従)は 2.14.0 で足した。既定にするのは新規インストールだけで、既存の利用者は
/// 保存した値が無くてもライトのまま(SettingsStore.adoptSystemAppearanceForNewInstall)。
enum AppAppearance: String, CaseIterable, Sendable {
  case system
  case light
  case dark

  var label: LocalizedStringResource {
    switch self {
    // iOS は「端末」、macOS は「システム」と呼び分ける(OS の設定アプリの呼び名に合わせる)。
    #if os(iOS)
      case .system: .appearanceSystemDevice
    #else
      case .system: .appearanceSystem
    #endif
    case .light: .appearanceLight
    case .dark: .appearanceDark
    }
  }

  /// 画面に指定する配色。`system` は nil(OS の設定に任せる)。
  var colorScheme: ColorScheme? {
    switch self {
    case .system: nil
    case .light: .light
    case .dark: .dark
    }
  }

  /// ダークで描くか。`system` は OS の今の配色(`systemScheme`)に従う。
  func isDark(system systemScheme: ColorScheme) -> Bool {
    (colorScheme ?? systemScheme) == .dark
  }
}

/// 学習中カードの並び。iOS 版のみの設定(macOS 版は独自のカードの格子を持つ)。
enum LearningCardLayout: String, CaseIterable, Sendable {
  case twoColumns
  case oneColumn

  var label: LocalizedStringResource {
    switch self {
    case .twoColumns: .layoutTwoColumns
    case .oneColumn: .layoutOneColumn
    }
  }

  /// 学習中グリッドの列数
  var columns: Int { self == .twoColumns ? 2 : 1 }
}

/// クイズの出題方向。表面に何を出すかを決める(既定は英語 → 訳)。
///
/// 値の名前は訳の言語が日本語だけだった頃のままにしている。UserDefaults に
/// 名前で保存しているため、変えると既存の設定が既定に戻ってしまう。
enum QuizDirection: String, CaseIterable, Sendable {
  case enToJa
  case jaToEn

  /// 設定画面の表示用ラベル(「英語 → 日本語」の「日本語」は訳の言語)
  func label(_ language: TranslationLanguage) -> LocalizedStringResource {
    switch self {
    case .enToJa: .quizDirectionFromEnglish(String(localized: language.shortLabel))
    case .jaToEn: .quizDirectionToEnglish(String(localized: language.shortLabel))
    }
  }
}

/// クイズの出題元(iOS のクイズの入口で選ぶ)。rawValue は UserDefaults に保存する名前で、計測の値も兼ねる。
///
/// 学習中・学習済みは状態、ブックマークは印なので重なりうる(ブックマークは学習状態に関係なく印の付いた単語)。
enum QuizSource: String, CaseIterable, Sendable {
  case learning
  case learned
  case bookmarks
  case all

  /// Pro で解放する出題元か。使い込んでいる人ほど欲しくなるものを Pro にし、
  /// 入口の離脱を減らす学習中・学習済みは無料にする(2026-11 のユーザーの判断)。
  var requiresPro: Bool { lockedOption != nil }

  /// Pro でないときに押されたら記録する値(quiz_option_locked_tapped)。無料の出題元は nil。
  var lockedOption: QuizLockedOption? {
    switch self {
    case .learning, .learned: nil
    case .bookmarks: .sourceBookmarks
    case .all: .sourceAll
    }
  }

  var label: LocalizedStringResource {
    switch self {
    case .learning: .quizSourceLearning
    case .learned: .quizSourceLearned
    case .bookmarks: .quizSourceBookmarks
    case .all: .quizSourceAll
    }
  }

  /// 全単語のうち、この出題元に入る単語。
  func words(from words: [Word]) -> [Word] {
    switch self {
    case .learning: WordListing.learning(words)
    case .learned: WordListing.learned(words)
    case .bookmarks: WordListing.bookmarked(words)
    case .all: words
    }
  }
}

/// クイズの 1 回の問題数。`all` は出題元を一巡する(50 問ごとに区切って結果を出す)。
///
/// 10 を既定(macOS は 10 問だけ)にするのは、回答ごとに lastReviewedAt を記録するので全単語を回す仕組みは
/// 区切りの長さに依存せず、区切りは結果画面(忘れた単語の見返し・レビュー依頼)に届くためのものだから。
/// 短い方が手軽に終えられ、結果画面にも届きやすい。
///
/// 20 を置かないのは、結果の「続ける」で 10 語ずつ進めるため 20 は「続ける」1 回と変わらないから。
/// 中間は 10 とはっきり違う量(30・50)にする(2026-11 のユーザーの判断)。
/// 10 だけを無料にする。解き終えるたびに全画面広告を出すので、無料で 1 回を長くすると広告の回数が減るため。
enum QuizQuestionCount: String, CaseIterable, Sendable {
  case ten
  case thirty
  case fifty
  case all

  /// 1 回(全部では 1 区切り)に出す最大の問題数。
  var limit: Int {
    switch self {
    case .ten: 10
    case .thirty: 30
    case .fifty, .all: 50
    }
  }

  var requiresPro: Bool { lockedOption != nil }

  /// Pro でないときに押されたら記録する値(quiz_option_locked_tapped)。無料の 10 問は nil。
  var lockedOption: QuizLockedOption? {
    switch self {
    case .ten: nil
    case .thirty: .countThirty
    case .fifty: .countFifty
    case .all: .countAll
    }
  }

  var label: LocalizedStringResource {
    switch self {
    case .ten: .quizCountTen
    case .thirty: .quizCountThirty
    case .fifty: .quizCountFifty
    case .all: .quizCountAll
    }
  }
}

/// 全単語一覧の並び順。学習中一覧・クイズ・エクスポートの並びには影響しない。
///
/// 「基準 + 昇順/降順」に分けず 8 通りを平らに持つのは、学習状態のように
/// 昇順・降順では意味が伝わらない基準があり、メニューでも 1 クリックで
/// 選ばせたいため。メニューの区切りは group で判定する。
enum WordSortOrder: String, CaseIterable, Sendable {
  case newest
  case oldest
  case alphabetical
  case reverseAlphabetical
  case learningFirst
  case learnedFirst
  case mostCorrect
  case leastCorrect

  /// 並べる基準。メニューで基準ごとに区切り線を入れるために使う。
  enum Group: Sendable {
    case createdAt
    case alphabet
    case learned
    case correctCount
  }

  var group: Group {
    switch self {
    case .newest, .oldest: .createdAt
    case .alphabetical, .reverseAlphabetical: .alphabet
    case .learningFirst, .learnedFirst: .learned
    case .mostCorrect, .leastCorrect: .correctCount
    }
  }

  /// メニューの表示用ラベル
  var label: String {
    switch self {
    case .newest: String(localized: .sortNewest)
    case .oldest: String(localized: .sortOldest)
    // アルファベット順はどの言語でも同じ表記なので訳さない
    case .alphabetical: "A → Z"
    case .reverseAlphabetical: "Z → A"
    case .learningFirst: String(localized: .sortLearningFirst)
    case .learnedFirst: String(localized: .sortLearnedFirst)
    case .mostCorrect: String(localized: .sortMostCorrect)
    case .leastCorrect: String(localized: .sortLeastCorrect)
    }
  }
}
