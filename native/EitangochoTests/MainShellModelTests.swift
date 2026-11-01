import Testing

@testable import Eitangocho

/// Flutter 版の MainPageNotifier の挙動と、test/app/main_page_notifier_test.dart(計測)を移したもの。
@MainActor
struct MainShellModelTests {
  @Test func 既定は学習中で検索語は空() {
    let model = MainShellModel(analytics: AnalyticsLogger(FakeAnalyticsClient()))
    #expect(model.view == .learning)
    #expect(model.searchQuery.isEmpty)
  }

  @Test func 画面と検索語を切り替えられる() {
    let model = MainShellModel(analytics: AnalyticsLogger(FakeAnalyticsClient()))
    model.selectView(.allWords)
    model.updateSearchQuery("ap")
    #expect(model.view == .allWords)
    #expect(model.searchQuery == "ap")
  }

  @Test func 検索欄へのフォーカスは検索欄のある画面でだけ受け付ける() {
    let model = MainShellModel(analytics: AnalyticsLogger(FakeAnalyticsClient()))
    model.focusSearch()
    #expect(model.searchFocusRequest == 1)
    model.selectView(.registration)
    model.focusSearch()
    #expect(model.searchFocusRequest == 1)
    #expect(MainView.allCases.filter(\.hasSearchField) == [.learning, .allWords])
  }

  @Test func iOSの検索欄は開くとフォーカスを当て何も打たずに離れたら閉じる() {
    let model = MainShellModel(analytics: AnalyticsLogger(FakeAnalyticsClient()))
    #expect(!model.isSearchOpen)
    model.openSearch()
    #expect(model.isSearchOpen)
    #expect(model.searchFocusRequest == 1)
    model.searchFocusLost()
    #expect(!model.isSearchOpen)
  }

  @Test func iOSの検索欄は検索語がある間は開いたままでキャンセルで消して閉じる() {
    let model = MainShellModel(analytics: AnalyticsLogger(FakeAnalyticsClient()))
    model.openSearch()
    model.updateSearchQuery("ap")
    model.searchFocusLost()
    // 画面を移っても開いたまま(学習中・全単語で検索語を共有する)。
    model.selectView(.allWords)
    #expect(model.isSearchOpen)
    model.cancelSearch()
    #expect(!model.isSearchOpen)
    #expect(model.searchQuery.isEmpty)
  }

  @Test func search_usedは検索語が空から非空になったときだけ画面を付けて送る() {
    let analytics = FakeAnalyticsClient()
    let model = MainShellModel(analytics: AnalyticsLogger(analytics))
    model.selectView(.allWords)
    // 打ち進めても、空白だけでも送らない。消して打ち直したら送る。
    for query in [" ", "a", "ap", "", "b"] {
      model.updateSearchQuery(query)
    }
    #expect(analytics.eventsNamed("search_used") == [["screen": "all_words"], ["screen": "all_words"]])
  }
}
