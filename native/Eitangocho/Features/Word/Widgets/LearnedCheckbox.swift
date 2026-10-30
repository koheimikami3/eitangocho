import SwiftUI

/// 学習済みチェック(18×18 角丸・白レ点)。Flutter 版の LearnedCheckbox。
/// 押せる範囲を広げるため、四辺に 6 の余白を持つ。
struct LearnedCheckbox: View {
  let value: Bool
  let onChange: (Bool) -> Void

  @Environment(\.colors) private var colors
  @Environment(\.uiScale) private var px

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: px(4))
    ZStack {
      shape.fill(value ? colors.accent : colors.inputFill)
      shape.strokeBorder(value ? colors.accent : colors.controlBorder, lineWidth: px(value ? 1 : 1.5))
      CheckMark()
        .fill(.white)
        .frame(width: px(6), height: px(11))
        // レ点は L 字(右+下の白い線)を 45 度回してから、少し左上へ寄せる。
        .rotationEffect(.degrees(45))
        .offset(x: px(-0.5), y: px(-1.5))
        .opacity(value ? 1 : 0)
    }
    .frame(width: px(18), height: px(18))
    .animation(.linear(duration: 0.15), value: value)
    .padding(px(6))
    .contentShape(Rectangle())
    .onTapGesture { onChange(!value) }
  }

  /// 右と下の太さ 2.5 の線でできた L 字(幅 6・高さ 11 の枠に対して)。
  private struct CheckMark: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
      let width = rect.width * 2.5 / 6
      var path = Path()
      path.addRect(CGRect(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
      path.addRect(CGRect(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
      return path
    }
  }
}
