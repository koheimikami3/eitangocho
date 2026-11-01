import SwiftUI

/// Flutter の `Wrap(spacing:, runSpacing:)` に当たる。左から並べ、収まらなければ次の行に送る。
struct FlowLayout: Layout {
  var spacing: CGFloat
  var runSpacing: CGFloat
  /// 行の中で上下中央に揃えるか(Wrap の crossAxisAlignment.center)。既定は上揃え(start)。
  var centersInRow = false

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let rows = arrange(subviews, maxWidth: proposal.width ?? .infinity)
    let width = rows.map(\.width).max() ?? 0
    let height = rows.map(\.height).reduce(0, +) + runSpacing * CGFloat(max(rows.count - 1, 0))
    return CGSize(width: width, height: height)
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    var y = bounds.minY
    for row in arrange(subviews, maxWidth: bounds.width) {
      var x = bounds.minX
      for (index, size) in zip(row.indices, row.sizes) {
        // 行の中では上に揃える(Wrap の既定の crossAxisAlignment.start)。centersInRow なら上下中央。
        let dy = centersInRow ? (row.height - size.height) / 2 : 0
        subviews[index].place(at: CGPoint(x: x, y: y + dy), proposal: ProposedViewSize(size))
        x += size.width + spacing
      }
      y += row.height + runSpacing
    }
  }

  private struct Row {
    var indices: [Int] = []
    var sizes: [CGSize] = []
    var width: CGFloat = 0
    var height: CGFloat = 0
  }

  private func arrange(_ subviews: Subviews, maxWidth: CGFloat) -> [Row] {
    var rows: [Row] = []
    var current = Row()
    // Wrap と同じく、子には行の幅を上限として渡す(長い単語などは行の幅の中で折り返す)。
    let proposal = ProposedViewSize(width: maxWidth.isFinite ? maxWidth : nil, height: nil)
    for index in subviews.indices {
      let size = subviews[index].sizeThatFits(proposal)
      let width = current.indices.isEmpty ? size.width : current.width + spacing + size.width
      if !current.indices.isEmpty && width > maxWidth {
        rows.append(current)
        current = Row()
      }
      current.width = current.indices.isEmpty ? size.width : current.width + spacing + size.width
      current.height = max(current.height, size.height)
      current.indices.append(index)
      current.sizes.append(size)
    }
    if !current.indices.isEmpty { rows.append(current) }
    return rows
  }
}
