import SwiftUI
import Testing

@testable import Eitangocho

struct MaterialIconTests {
  /// Material の search は 24 の枠の (3, 3)〜(20.49, 20.49) に収まる(Material Icons の SVG と同じ)。
  @Test func 輪郭を読んで枠に広げられる() {
    let bounds = MaterialIconShape(icon: .search).path(in: CGRect(x: 0, y: 0, width: 24, height: 24)).boundingRect
    #expect(abs(bounds.minX - 3) < 0.05)
    #expect(abs(bounds.minY - 3) < 0.05)
    #expect(abs(bounds.maxX - 20.49) < 0.05)
    #expect(abs(bounds.maxY - 20.49) < 0.05)
  }

  @Test(arguments: [MaterialIcon.check, .expandMore, .search, .volumeUp])
  func どのアイコンも空でない輪郭になる(icon: MaterialIcon) {
    let bounds = MaterialIconShape(icon: icon).path(in: CGRect(x: 0, y: 0, width: 1, height: 1)).boundingRect
    #expect(bounds.width > 0.3)
    #expect(bounds.minX >= 0 && bounds.maxX <= 1)
  }
}
