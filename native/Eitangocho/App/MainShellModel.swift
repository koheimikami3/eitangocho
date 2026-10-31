import Foundation
import Observation

/// シェルで切り替える画面。既定は学習中。
enum MainView: CaseIterable, Sendable {
  case learning
  case allWords
  case quiz
  case registration
  case settings

  /// ツールバーに検索欄を持つ画面か。⌘F(検索欄へのフォーカス)の有効 / 無効の判定に使う。
  var hasSearchField: Bool { self == .learning || self == .allWords }

  /// ツールバーの見出し。
  var title: LocalizedStringResource {
    switch self {
    case .learning: .navLearningWords
    case .allWords: .navAllWords
    case .quiz: .navQuiz
    case .registration: .navRegistration
    case .settings: .navSettings
    }
  }
}

/// 表示中の画面と検索語(Flutter 版の MainPageNotifier)。
@Observable
final class MainShellModel {
  private(set) var view: MainView = .learning
  private(set) var searchQuery = ""

  /// ⌘F で検索欄にフォーカスを当てる合図。値が変わるたびに検索欄が受け取る。
  /// iOS はヘッダの 🔍 で検索欄を開いたときにも上げる。
  private(set) var searchFocusRequest = 0

  /// iOS のヘッダに検索欄を開いているか。検索語がある間は開いたままにする
  /// (閉じると絞り込み中であることが見えなくなるため)。学習中・全単語で共有する。
  private(set) var isSearchOpen = false

  @ObservationIgnored private let analytics: AnalyticsLogger

  init(analytics: AnalyticsLogger) {
    self.analytics = analytics
  }

  func selectView(_ view: MainView) {
    self.view = view
  }

  func updateSearchQuery(_ query: String) {
    // 検索を使い始めた(空 → 非空)ときに 1 回だけ送る。打つたびには送らない。
    // 送るのは画面だけで、検索語そのものは送らない。
    if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      analytics.logSearchUsed(view)
    }
    searchQuery = query
  }

  /// 検索欄のある画面でだけ受け付ける(メニューの ⌘F)。
  func focusSearch() {
    guard view.hasSearchField else { return }
    searchFocusRequest += 1
  }

  /// iOS のヘッダの 🔍。検索欄を開いてフォーカスを当てる(開いていればフォーカスだけ)。
  func openSearch() {
    isSearchOpen = true
    searchFocusRequest += 1
  }

  /// iOS の検索欄の「キャンセル」。検索語を消して閉じる。
  func cancelSearch() {
    updateSearchQuery("")
    isSearchOpen = false
  }

  /// iOS の検索欄からフォーカスが外れた。何も打たずに離れたなら閉じる(検索語があれば開いたまま)。
  func searchFocusLost() {
    if searchQuery.isEmpty { isSearchOpen = false }
  }
}
