#if os(iOS)
  import SwiftUI

  /// iOS 版の学習済みチェック(22x22・角丸 6。Flutter 版の MobileLearnedCheckbox)。
  ///
  /// macOS 版の LearnedCheckbox より一回り大きい。押せる範囲を稼ぐため、周りのラベルごと囲んで使う
  /// (このビュー自身はチェックの部分だけ)。
  struct MobileLearnedCheckbox: View {
    let value: Bool

    @Environment(\.palette) private var palette

    var body: some View {
      let shape = RoundedRectangle(cornerRadius: 6)
      ZStack {
        shape.fill(value ? palette.accent : .clear)
        shape.strokeBorder(value ? palette.accent : palette.checkOffBorder, lineWidth: 1.5)
        // デザインと同じ作り方(縦長の枠の右辺・下辺だけを 2px で描いて 45 度回す)。
        // Icons.check は線が細く、22x22 の枠の中では小さく見えるため。
        // 回転させると視覚的な重心が下がるので、回転後の座標系で少し戻す。
        CheckMark()
          .fill(.white)
          .frame(width: 7, height: 12)
          .offset(x: -0.5, y: -1)
          .rotationEffect(.degrees(45))
          .opacity(value ? 1 : 0)
      }
      .frame(width: 22, height: 22)
      .animation(.linear(duration: 0.15), value: value)
    }

    /// 右と下の太さ 2 の線でできた L 字。
    private struct CheckMark: Shape {
      nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(CGRect(x: rect.maxX - 2, y: rect.minY, width: 2, height: rect.height))
        path.addRect(CGRect(x: rect.minX, y: rect.maxY - 2, width: rect.width, height: 2))
        return path
      }
    }
  }
#endif
