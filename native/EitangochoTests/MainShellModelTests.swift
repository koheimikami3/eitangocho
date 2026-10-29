import Testing

@testable import Eitangocho

/// Flutter 版の MainPageNotifier の挙動(test/app/main_page_notifier_test.dart は計測だけなので、
/// 計測は Phase 4 で移す)。
@MainActor
struct MainShellModelTests {
  @Test func 既定は学習中で検索語は空() {
    let model = MainShellModel()
    #expect(model.view == .learning)
    #expect(model.searchQuery.isEmpty)
  }

  @Test func 画面と検索語を切り替えられる() {
    let model = MainShellModel()
    model.selectView(.allWords)
    model.updateSearchQuery("ap")
    #expect(model.view == .allWords)
    #expect(model.searchQuery == "ap")
  }

  @Test func 検索欄へのフォーカスは検索欄のある画面でだけ受け付ける() {
    let model = MainShellModel()
    model.focusSearch()
    #expect(model.searchFocusRequest == 1)
    model.selectView(.registration)
    model.focusSearch()
    #expect(model.searchFocusRequest == 1)
    #expect(MainView.allCases.filter(\.hasSearchField) == [.learning, .allWords])
  }
}
