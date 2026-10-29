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
  private(set) var searchFocusRequest = 0

  func selectView(_ view: MainView) {
    self.view = view
  }

  func updateSearchQuery(_ query: String) {
    searchQuery = query
  }

  /// 検索欄のある画面でだけ受け付ける(メニューの ⌘F)。
  func focusSearch() {
    guard view.hasSearchField else { return }
    searchFocusRequest += 1
  }
}
