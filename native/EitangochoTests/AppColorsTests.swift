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

  /// テーマカラーごとのライト / ダーク(2.18.0 から macOS もテーマカラーを選べる)。
  nonisolated private static let themed = ThemeColor.allCases.flatMap { theme in
    [AppColors(isDark: false, theme: theme), AppColors(isDark: true, theme: theme)]
  }

  @Test(arguments: themed)
  func 発音ボタンの文字とアイコンは淡い地に対して4_5対1以上ある(colors: AppColors) {
    // ラベルは 12〜13px で「大きい文字」の 3:1 基準は使えないため 4.5:1 を要求する。
    #expect(ColorContrast.ratio(colors.accentOnSoft, colors.accentSoft, colors.surface) >= 4.5)
    // hover は地が濃くなるぶんコントラストが下がる。ここも割らない。
    #expect(ColorContrast.ratio(colors.accentOnSoft, colors.accentSoftHover, colors.surface) >= 4.5)
  }

  @Test(arguments: themed)
  func カード地に直接載るアクセントの文字は4_5対1以上ある(colors: AppColors) {
    #expect(ColorContrast.ratio(colors.accentOnSoft, colors.surface, colors.surface) >= 4.5)
  }

  @Test(arguments: [false, true])
  func ブルーのアクセント系の値は2_17_0までと同じ(isDark: Bool) {
    // テーマカラーから作るようにしても、既定のブルーの見た目は変えない。
    let colors = AppColors(isDark: isDark, theme: .blue)
    let expected: [(Color, UInt32)] = [
      (colors.accent, 0xFF42_9FF0), (colors.accentHover, 0xFF2B_8EE0),
      (colors.accentSoft, isDark ? 0x3842_9FF0 : 0x1A42_9FF0),
      (colors.accentSoftHover, isDark ? 0x5242_9FF0 : 0x3342_9FF0),
      (colors.accentLine, isDark ? 0x737E_C2FF : 0x6142_9FF0),
      (colors.accentLineHover, isDark ? 0xA67E_C2FF : 0x9942_9FF0),
      (colors.accentOnSoft, isDark ? 0xFF7E_C2FF : 0xFF17_6AB4),
      (colors.buttonGradient[0], isDark ? 0xFF44_9DF0 : 0xFF4D_A4F2),
      (colors.buttonGradient[1], isDark ? 0xFF37_95E9 : 0xFF3F_9CEF),
      (colors.buttonGradientHover[0], 0xFF3F_9CEF),
    ]
    for (color, argb) in expected {
      #expect(color == Color(argb: argb), "\(String(argb, radix: 16))")
    }
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
