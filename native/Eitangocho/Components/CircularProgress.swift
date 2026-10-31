import SwiftUI

/// 読み込み中の表示(Flutter の CircularProgressIndicator: 既定は一辺 36・線の太さ 4 の回る弧)。
struct CircularProgress: View {
  let color: Color
  var size: CGFloat = 36
  var lineWidth: CGFloat = 4

  @Environment(\.uiScale) private var px
  @State private var rotating = false

  var body: some View {
    Circle()
      .trim(from: 0, to: 0.75)
      .stroke(color, style: StrokeStyle(lineWidth: px(lineWidth), lineCap: .square))
      .frame(width: px(size), height: px(size))
      .rotationEffect(.degrees(rotating ? 360 : 0))
      .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotating)
      .onAppear { rotating = true }
  }
}
