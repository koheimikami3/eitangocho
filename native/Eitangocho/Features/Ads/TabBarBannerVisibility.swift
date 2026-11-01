import Foundation

/// タブバー上のバナーを出してよい画面か(Flutter 版の tabBarBannerVisibleProvider)。
///
/// 隠すのはクイズ結果だけ。あそこには 300x250 のレクタングルが出るため、両方並べると画面の 4 割が
/// 広告になり、忘れていた単語の一覧がほとんど読めなくなる。大きい方(レクタングル)を優先する。
///
/// レクタングルのユニットが未設定なら隠さない。広告がゼロの画面を作っても意味がないため。
enum TabBarBannerVisibility {
  static func isVisible(
    view: MainView, quizPhase: QuizModel.Phase, quizRectangleUnit: String = AdUnitIds.quizRectangle
  ) -> Bool {
    if quizRectangleUnit.isEmpty { return true }
    if view != .quiz { return true }
    if case .done = quizPhase { return false }
    return true
  }
}
