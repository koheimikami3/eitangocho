import SwiftUI

/// 読み込み中の表示(Flutter の CircularProgressIndicator: 既定は一辺 36・線の太さ 4 の回る弧)。
struct CircularProgress: View {
  let color: Color
  var size: CGFloat = 36
  var lineWidth: CGFloat = 4
  /// 弧の下に敷く輪の色(Flutter の backgroundColor)。nil なら敷かない。
  var trackColor: Color?

  @Environment(\.uiScale) private var px
  @State private var rotating = false

  var body: some View {
    ZStack {
      if let trackColor {
        Circle().stroke(trackColor, lineWidth: px(lineWidth))
      }
      arc
    }
    .frame(width: px(size), height: px(size))
  }

  private var arc: some View {
    Circle()
      .trim(from: 0, to: 0.75)
      .stroke(color, style: StrokeStyle(lineWidth: px(lineWidth), lineCap: .square))
      // 繰り返しのアニメーションは回転だけに掛ける。`.animation(_:value:)` で掛けると、出た瞬間に親の
      // レイアウトが動いた分(位置の変化)まで繰り返し動かし続け、弧だけが下の輪からずれて回る
      // (クイズを解き終えた直後の「広告を表示します」で起きた)。
      .animation(.linear(duration: 1).repeatForever(autoreverses: false)) { content in
        content.rotationEffect(.degrees(rotating ? 360 : 0))
      }
      .onAppear { rotating = true }
  }
}
