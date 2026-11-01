import Foundation
import Testing

@testable import Eitangocho

/// 発音確認のページの読み込みの状態の移り方。
struct PronunciationPageLoadTests {
  private let offline = URLError(.notConnectedToInternet)

  @Test func 最初の表示の前に失敗したら引き直せる画面にする() {
    var load = PronunciationPageLoad()
    load.started()
    load.failed(offline)

    #expect(!load.isLoading)
    #expect(load.hasError)
  }

  @Test func 表示できた後の遷移が失敗したら覆いを外して元のページを残す() {
    var load = PronunciationPageLoad()
    load.started()
    load.finished()
    // ページ内のリンクなどで次の遷移が始まり、通信断で失敗した。
    load.started()
    load.failed(offline)

    #expect(!load.isLoading)
    #expect(!load.hasError)
  }

  @Test func 遷移の中断は失敗にしない() {
    var load = PronunciationPageLoad()
    load.started()
    load.failed(URLError(.cancelled))

    #expect(load.isLoading)
    #expect(!load.hasError)
  }

  @Test func 引き直すと読み込み中に戻る() {
    var load = PronunciationPageLoad()
    load.failed(offline)
    load.reload()

    #expect(load.isLoading)
    #expect(!load.hasError)
  }
}
