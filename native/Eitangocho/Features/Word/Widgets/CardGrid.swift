import SwiftUI

/// 学習中のカードの格子。幅に収まる最大の列数を求め、間隔で等分した幅でカードを並べる
/// (CSS の repeat(auto-fill, minmax(260px, 1fr)) 相当。Flutter 版の LearningWordsView の LayoutBuilder)。
/// カードの高さはそろえず、行ごとに上に揃える(Flutter の Wrap と同じ)。
struct CardGrid: Layout {
  var minWidth: CGFloat
  var gap: CGFloat

  private func cardWidth(_ width: CGFloat) -> CGFloat {
    let columns = max(Int(((width + gap) / (minWidth + gap)).rounded(.down)), 1)
    return (width - gap * CGFloat(columns - 1)) / CGFloat(columns)
  }

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let width = proposal.width ?? minWidth
    return CGSize(width: width, height: rows(subviews, width: width).last.map { $0.y + $0.height } ?? 0)
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    let card = cardWidth(bounds.width)
    for row in rows(subviews, width: bounds.width) {
      for (column, index) in row.indices.enumerated() {
        subviews[index].place(
          at: CGPoint(x: bounds.minX + CGFloat(column) * (card + gap), y: bounds.minY + row.y),
          proposal: ProposedViewSize(width: card, height: nil))
      }
    }
  }

  private struct Row {
    var indices: [Int]
    var y: CGFloat
    var height: CGFloat
  }

  private func rows(_ subviews: Subviews, width: CGFloat) -> [Row] {
    let card = cardWidth(width)
    let columns = max(Int(((width + gap) / (minWidth + gap)).rounded(.down)), 1)
    var result: [Row] = []
    var y: CGFloat = 0
    for start in stride(from: 0, to: subviews.count, by: columns) {
      let indices = Array(start..<min(start + columns, subviews.count))
      let height = indices.map { subviews[$0].sizeThatFits(ProposedViewSize(width: card, height: nil)).height }.max() ?? 0
      result.append(Row(indices: indices, y: y, height: height))
      y += height + gap
    }
    return result
  }
}
