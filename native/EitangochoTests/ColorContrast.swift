import Foundation
import SwiftUI

/// 配色のテストで使うコントラスト比(WCAG)の計算。Flutter 版の test/constants/app_palette_test.dart と同じ式。
enum ColorContrast {
  struct RGBA {
    var r: Double
    var g: Double
    var b: Double
    var a: Double

    init(_ color: Color) {
      let resolved = color.resolve(in: EnvironmentValues())
      r = Double(resolved.red)
      g = Double(resolved.green)
      b = Double(resolved.blue)
      a = Double(resolved.opacity)
    }

    init(r: Double, g: Double, b: Double, a: Double) {
      self.r = r
      self.g = g
      self.b = b
      self.a = a
    }

    /// `under` の上に重ねた不透明な色(sRGB のまま混ぜる。Flutter の Color.lerp と同じ)。
    func over(_ under: RGBA) -> RGBA {
      RGBA(r: r * a + under.r * (1 - a), g: g * a + under.g * (1 - a), b: b * a + under.b * (1 - a), a: 1)
    }

    /// WCAG の相対輝度(不透明な色に対して)。
    var luminance: Double {
      func channel(_ v: Double) -> Double { v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }
      return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)
    }
  }

  /// `foreground` を `background` の上に載せたときのコントラスト比。
  /// 背景が半透明なら `under`(その下の面)と合成してから測る。
  static func ratio(_ foreground: Color, _ background: Color, _ under: Color) -> Double {
    let composited = RGBA(background).over(RGBA(under))
    let backgroundLuminance = composited.luminance
    let foregroundLuminance = RGBA(foreground).over(composited).luminance
    return (max(backgroundLuminance, foregroundLuminance) + 0.05)
      / (min(backgroundLuminance, foregroundLuminance) + 0.05)
  }
}
