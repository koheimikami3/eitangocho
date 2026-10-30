import SwiftUI

/// 読み込み中の表示(Flutter の CircularProgressIndicator: 一辺 36・線の太さ 4 の回る弧)。
struct CircularProgress: View {
  let color: Color

  @Environment(\.uiScale) private var px
  @State private var rotating = false

  var body: some View {
    Circle()
      .trim(from: 0, to: 0.75)
      .stroke(color, style: StrokeStyle(lineWidth: px(4), lineCap: .square))
      .frame(width: px(36), height: px(36))
      .rotationEffect(.degrees(rotating ? 360 : 0))
      .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotating)
      .onAppear { rotating = true }
  }
}
