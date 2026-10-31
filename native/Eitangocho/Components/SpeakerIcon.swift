import SwiftUI

/// 発音ボタンのスピーカーアイコン(Flutter 版の SpeakerIcon)。
///
/// Material の `Icons.volume_up` は音波が 3 本でデザインと形が違うため、
/// デザインの SVG(16×16 viewBox の 2 パス)をそのまま描く。
/// 塗りの本体 + 線の音波 1 本という構成で、線幅もアイコンの大きさに追従させる。
struct SpeakerIcon: View {
  /// 一辺の長さ(素の値)。
  let size: CGFloat
  let color: Color

  @Environment(\.uiScale) private var px

  /// デザインの SVG の viewBox。この座標系で組んでから実寸に拡大する。
  private static let viewBox: CGFloat = 16
  /// 音波の線幅(viewBox 基準)。
  private static let waveStrokeWidth: CGFloat = 1.3

  var body: some View {
    Canvas { context, canvasSize in
      let scale = canvasSize.width / Self.viewBox
      let transform = CGAffineTransform(scaleX: scale, y: scale)
      // 本体: M3 6.2v3.6h2.5L8.7 12.3V3.7L5.5 6.2H3z
      var body = Path()
      body.move(to: CGPoint(x: 3, y: 6.2))
      body.addLine(to: CGPoint(x: 3, y: 9.8))
      body.addLine(to: CGPoint(x: 5.5, y: 9.8))
      body.addLine(to: CGPoint(x: 8.7, y: 12.3))
      body.addLine(to: CGPoint(x: 8.7, y: 3.7))
      body.addLine(to: CGPoint(x: 5.5, y: 6.2))
      body.closeSubpath()
      context.fill(body.applying(transform), with: .color(color))
      // 音波: M10.8 5.8c0.8 0.5 1.3 1.3 1.3 2.2s-0.5 1.7-1.3 2.2(smooth curve を展開して書く)
      var wave = Path()
      wave.move(to: CGPoint(x: 10.8, y: 5.8))
      wave.addCurve(to: CGPoint(x: 12.1, y: 8), control1: CGPoint(x: 11.6, y: 6.3), control2: CGPoint(x: 12.1, y: 7.1))
      wave.addCurve(to: CGPoint(x: 10.8, y: 10.2), control1: CGPoint(x: 12.1, y: 8.9), control2: CGPoint(x: 11.6, y: 9.7))
      context.stroke(
        wave.applying(transform), with: .color(color),
        style: StrokeStyle(lineWidth: Self.waveStrokeWidth * scale, lineCap: .round))
    }
    .frame(width: px(size), height: px(size))
  }
}
