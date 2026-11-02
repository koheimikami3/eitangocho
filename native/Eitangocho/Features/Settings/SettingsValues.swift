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
