import SwiftUI
import Testing

@testable import Eitangocho

/// AppOverlay の層を出すときの振る舞い。
@MainActor
struct AppOverlayTests {
  @Test func ダイアログもシートも押し出す画面も出す前に下の入力欄のフォーカスを外す() {
    let overlay = AppOverlay()
    var endEditingCount = 0
    overlay.endEditing = { endEditingCount += 1 }

    overlay.present { _ in EmptyView() }
    #expect(endEditingCount == 1)
    overlay.presentSheet { _ in EmptyView() }
    #expect(endEditingCount == 2)
    overlay.push { EmptyView() }
    #expect(endEditingCount == 3)
  }
}
