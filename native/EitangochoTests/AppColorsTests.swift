import EitangochoData
import Foundation
import SwiftUI
import Testing

@testable import Eitangocho

/// Flutter 版の test/constants/app_palette_test.dart のうち、macOS の配色と品詞バッジのコントラストを移したもの。
struct AppColorsTests {
  @Test(arguments: [AppColors.light, AppColors.dark])
  func 品詞バッジの文字は背景に対して4_5対1以上ある(colors: AppColors) {
    for pos in PartOfSpeech.allCases {
      let (background, foreground) = pos.badgeColors(colors)
      // チップはカードの上に乗るため、半透明の背景はカード面と合成する。
      #expect(ColorContrast.ratio(foreground, background, colors.surface) >= 4.5, "\(colors.isDark) \(pos)")
    }
  }

  @Test(arguments: [AppColors.light, AppColors.dark])
  func 発音ボタンの文字とアイコンは淡い地に対して4_5対1以上ある(colors: AppColors) {
    // ラベルは 12〜13px で「大きい文字」の 3:1 基準は使えないため 4.5:1 を要求する。
    #expect(ColorContrast.ratio(colors.accentOnSoft, colors.accentSoft, colors.surface) >= 4.5)
    // hover は地が濃くなるぶんコントラストが下がる。ここも割らない。
    #expect(ColorContrast.ratio(colors.accentOnSoft, colors.accentSoftHover, colors.surface) >= 4.5)
  }

  @Test(arguments: [AppColors.light, AppColors.dark])
  func カード地に直接載る青文字は4_5対1以上ある(colors: AppColors) {
    #expect(ColorContrast.ratio(colors.accentOnSoft, colors.surface, colors.surface) >= 4.5)
  }

  @Test func Flutter版と同じ値を写している() {
    // 写し間違いの検出用に、代表の値を Flutter 版の定義と突き合わせる。
    let accent = ColorContrast.RGBA(AppColors.light.accent)
    #expect(Int((accent.r * 255).rounded()) == 0x42)
    #expect(Int((accent.g * 255).rounded()) == 0x9F)
    #expect(Int((accent.b * 255).rounded()) == 0xF0)
    let menu = ColorContrast.RGBA(AppColors.dark.menuBackground)
    #expect(abs(menu.a - 0.98) < 0.001)
  }
}
