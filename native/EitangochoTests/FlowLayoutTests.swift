import AppKit
import SwiftUI
import Testing

@testable import Eitangocho

/// Flutter の Wrap と同じ折り返しになることを確かめる(品詞チップ・品詞バッジの並び)。
@MainActor
struct FlowLayoutTests {
  private func size(width: CGFloat) -> CGSize {
    let view = FlowLayout(spacing: 8, runSpacing: 4) {
      ForEach(0..<3, id: \.self) { _ in Color.red.frame(width: 50, height: 20) }
    }
    .frame(width: width)
    .fixedSize(horizontal: false, vertical: true)
    return NSHostingView(rootView: view).fittingSize
  }

  @Test func 収まる間は1行に並べる() {
    #expect(size(width: 166).height == 20)
  }

  @Test func 収まらない分は次の行に送り行間を空ける() {
    // 50 + 8 + 50 = 108 まで 1 行。3 つ目は次の行。
    #expect(size(width: 120).height == 44)
    #expect(size(width: 50).height == 68)
  }
}
