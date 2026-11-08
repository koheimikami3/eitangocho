import SwiftUI

/// ブックマークの印(しおりの形)。iOS / macOS の 🔖 のボタンと絞り込みで使う。
///
/// OS 標準の bookmark の絵柄は縦長で幅が狭く、小さく置くと棒のように見えるため、幅の広いしおりの形を自前で描く
/// (2026-11-08 のユーザーの指摘)。付いていれば塗り、無ければ線だけにする。
struct BookmarkIcon: View {
  let filled: Bool
  let color: Color
  /// 高さ。幅は高さの `aspectRatio` 倍。
  var height: CGFloat = 16

  /// 幅 / 高さ。OS 標準(約 0.6)より広くする。
  static let aspectRatio: CGFloat = 0.8

  var body: some View {
    let width = height * Self.aspectRatio
    let lineWidth = max(height * 0.1, 1.2)
    Group {
      if filled {
        BookmarkShape().fill(color)
      } else {
        // 線は形の内側に収める(外にはみ出すと塗りのときより大きく見えるため)。
        BookmarkShape()
          .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round))
          .padding(lineWidth / 2)
      }
    }
    .frame(width: width, height: height)
  }
}

/// しおりの形。上の角を少し丸め、下は中央を V 字に切り込む。
nonisolated struct BookmarkShape: Shape {
  func path(in rect: CGRect) -> Path {
    let radius = rect.width * 0.16
    // 切り込みの深さ(高さに対する割合)。
    let notch = rect.height * 0.24
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
    path.addQuadCurve(
      to: CGPoint(x: rect.minX + radius, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
    path.addQuadCurve(
      to: CGPoint(x: rect.maxX, y: rect.minY + radius), control: CGPoint(x: rect.maxX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - notch))
    path.closeSubpath()
    return path
  }
}
