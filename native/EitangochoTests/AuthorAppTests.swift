import Foundation
import Testing

@testable import Eitangocho

/// 設定の「作者の他のアプリ」の一覧(Flutter 版の AuthorApp と同じ中身であること)。
struct AuthorAppTests {
  @Test func Flutter版と同じ順と中身() {
    #expect(AuthorApp.all.map(\.name) == ["サブリス", "メトロノーム"])
    #expect(AuthorApp.all.map(\.tagline) == ["サブスクと固定費をリストで管理", "拍子・テンポ・BPM"])
    #expect(AuthorApp.all.allSatisfy { $0.availability == "無料 · iPhone" })
    #expect(
      AuthorApp.all.map(\.appStoreURL.absoluteString) == [
        "https://apps.apple.com/jp/app/id1661226530", "https://apps.apple.com/jp/app/id6814060706",
      ])
  }

  @Test func アイコンを同梱している() {
    for app in AuthorApp.all {
      #expect(Bundle.main.url(forResource: app.iconName, withExtension: "png") != nil, "\(app.iconName)")
    }
  }
}
