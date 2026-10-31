import Testing

@testable import Eitangocho

/// Flutter 版の test/features/ads/presentation/tab_bar_banner_visible_provider_test.dart を移したもの。
/// Flutter 版はクイズを実際に進めて結果の画面にしていたが、判定は表示中の画面とクイズの段階だけで
/// 決まるので、段階を直接渡す(クイズの進行そのものは QuizModelTests が見ている)。
struct TabBarBannerVisibilityTests {
  @Test func クイズ以外のビューでは出す() {
    #expect(TabBarBannerVisibility.isVisible(view: .learning, quizPhase: .done))
  }

  @Test func 出題中のクイズでは出す() {
    // レクタングルはまだ出ていない。
    #expect(TabBarBannerVisibility.isVisible(view: .quiz, quizPhase: .active))
  }

  @Test func クイズ結果ではレクタングルに譲って引っ込む() {
    #expect(!TabBarBannerVisibility.isVisible(view: .quiz, quizPhase: .done))
  }

  @Test func レクタングルのユニットが未設定なら隠さない() {
    #expect(TabBarBannerVisibility.isVisible(view: .quiz, quizPhase: .done, quizRectangleUnit: ""))
  }
}
