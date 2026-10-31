import SwiftUI

nonisolated extension Color {
  /// Flutter の `Color(0xAARRGGBB)` と同じ書き方で色を作る(sRGB)。
  /// トークンの値を Flutter 版の定義からそのまま写せるようにするため。
  init(argb: UInt32) {
    self.init(
      .sRGB,
      red: Double((argb >> 16) & 0xFF) / 255,
      green: Double((argb >> 8) & 0xFF) / 255,
      blue: Double(argb & 0xFF) / 255,
      opacity: Double((argb >> 24) & 0xFF) / 255
    )
  }

  /// Flutter の `Color.fromRGBO(r, g, b, opacity)` と同じ書き方。
  init(r: Int, g: Int, b: Int, opacity: Double) {
    self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: opacity)
  }
}
