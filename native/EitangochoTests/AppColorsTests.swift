import EitangochoData
import Foundation
import SwiftUI
import Testing

@testable import Eitangocho

/// Flutter 版の test/constants/app_palette_test.dart のうち、macOS の配色と品詞バッジのコントラストを移したもの。
struct AppColorsTests {
  private struct RGBA {
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
  private func contrastRatio(_ foreground: Color, _ background: Color, _ under: Color) -> Double {
    let composited = RGBA(background).over(RGBA(under))
    let backgroundLuminance = composited.luminance
    let foregroundLuminance = RGBA(foreground).over(composited).luminance
    return (max(backgroundLuminance, foregroundLuminance) + 0.05)
      / (min(backgroundLuminance, foregroundLuminance) + 0.05)
  }

  @Test(arguments: [AppColors.light, AppColors.dark])
  func 品詞バッジの文字は背景に対して4_5対1以上ある(colors: AppColors) {
    for pos in PartOfSpeech.allCases {
      let (background, foreground) = pos.badgeColors(colors)
      // チップはカードの上に乗るため、半透明の背景はカード面と合成する。
      #expect(contrastRatio(foreground, background, colors.surface) >= 4.5, "\(colors.isDark) \(pos)")
    }
  }

  @Test(arguments: [AppColors.light, AppColors.dark])
  func 発音ボタンの文字とアイコンは淡い地に対して4_5対1以上ある(colors: AppColors) {
    // ラベルは 12〜13px で「大きい文字」の 3:1 基準は使えないため 4.5:1 を要求する。
    #expect(contrastRatio(colors.accentOnSoft, colors.accentSoft, colors.surface) >= 4.5)
    // hover は地が濃くなるぶんコントラストが下がる。ここも割らない。
    #expect(contrastRatio(colors.accentOnSoft, colors.accentSoftHover, colors.surface) >= 4.5)
  }

  @Test(arguments: [AppColors.light, AppColors.dark])
  func カード地に直接載る青文字は4_5対1以上ある(colors: AppColors) {
    #expect(contrastRatio(colors.accentOnSoft, colors.surface, colors.surface) >= 4.5)
  }

  @Test func Flutter版と同じ値を写している() {
    // 写し間違いの検出用に、代表の値を Flutter 版の定義と突き合わせる。
    let accent = RGBA(AppColors.light.accent)
    #expect(Int((accent.r * 255).rounded()) == 0x42)
    #expect(Int((accent.g * 255).rounded()) == 0x9F)
    #expect(Int((accent.b * 255).rounded()) == 0xF0)
    let menu = RGBA(AppColors.dark.menuBackground)
    #expect(abs(menu.a - 0.98) < 0.001)
  }
}
