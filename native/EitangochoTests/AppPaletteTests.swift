import EitangochoData
import SwiftUI
import Testing

@testable import Eitangocho

/// Flutter 版の test/constants/app_palette_test.dart のうち、iOS の配色を移したもの
/// (macOS の配色と品詞バッジのライトは AppColorsTests)。
struct AppPaletteTests {
  private func hex(_ color: Color) -> [Int] {
    let rgba = ColorContrast.RGBA(color)
    return [rgba.r, rgba.g, rgba.b].map { Int(($0 * 255).rounded()) }
  }

  @Test func ライトとダークで地の色と本文色が入れ替わる() {
    #expect(!AppPalette.light.isDark)
    #expect(AppPalette.dark.isDark)
    // --bg(ライトは 2.2.0 の値)/ --text の値。
    #expect(hex(AppPalette.light.background) == [0xF7, 0xF8, 0xFA])
    #expect(hex(AppPalette.dark.background) == [0x13, 0x13, 0x15])
    #expect(hex(AppPalette.light.text) == [0x1D, 0x1D, 0x1F])
    #expect(hex(AppPalette.dark.text) == [0xF5, 0xF5, 0xF7])
  }

  @Test func ブルーのアクセント色はライトとダークで共通() {
    #expect(AppPalette.dark.accent == AppPalette.light.accent)
  }

  @Test func ブルーのアクセント系の値は2_13_0までと同じ() {
    let light = AppPalette.light
    let dark = AppPalette.dark
    #expect(hex(light.accent) == [0x42, 0x9F, 0xF0])
    #expect(hex(light.accentOnSoft) == [0x1B, 0x78, 0xC2])
    #expect(hex(dark.accentOnSoft) == [0x7E, 0xC2, 0xFF])
    #expect(light.buttonGradient.map(hex) == [[0x4D, 0xA4, 0xF2], [0x3F, 0x9C, 0xEF]])
    #expect(dark.buttonGradient.map(hex) == [[0x44, 0x9D, 0xF0], [0x37, 0x95, 0xE9]])
  }

  @Test func グラファイトだけダークでアクセントを明るくする() {
    for theme in ThemeColor.allCases {
      let light = AppPalette(isDark: false, theme: theme)
      let dark = AppPalette(isDark: true, theme: theme)
      #expect((light.accent != dark.accent) == (theme == .graphite), "\(theme)")
    }
  }

  @Test func textAlphaとborderAlphaはライトが黒ベースでダークが白ベース() {
    let light = ColorContrast.RGBA(AppPalette.light.textAlpha(70))
    let dark = ColorContrast.RGBA(AppPalette.dark.textAlpha(70))
    #expect(light.r == 0)
    #expect(abs(light.a - 0.7) < 0.01)
    #expect(dark.r == 1)
    #expect(abs(dark.a - 0.7) < 0.01)
    #expect(ColorContrast.RGBA(AppPalette.light.borderAlpha(10)).r == 0)
    #expect(ColorContrast.RGBA(AppPalette.dark.borderAlpha(10)).r == 1)
  }

  @Test func 品詞バッジはライトとダークで別配色になる() {
    for pos in PartOfSpeech.allCases {
      let light = pos.badgeColors(AppPalette.light)
      let dark = pos.badgeColors(AppPalette.dark)
      #expect(light.background != dark.background, "\(pos) の背景")
      #expect(light.foreground != dark.foreground, "\(pos) の文字色")
    }
  }

  @Test(arguments: [AppPalette.light, AppPalette.dark])
  func 品詞バッジの文字は背景に対して4_5対1以上ある(palette: AppPalette) {
    for pos in PartOfSpeech.allCases {
      let (background, foreground) = pos.badgeColors(palette)
      // チップはカードの上に乗るため、半透明の背景はカード面と合成する。
      #expect(ColorContrast.ratio(foreground, background, palette.surface) >= 4.5, "\(palette.isDark) \(pos)")
    }
  }

  @Test(arguments: ThemeColor.allCases)
  func 発音ボタンの文字とアイコンはダークの淡い地に対して4_5対1以上ある(theme: ThemeColor) {
    // iOS のライトは刷新案 A のデザイン判断で #1B78C2(4.14:1)を採用しており例外とする(AppPalette.accentOnSoft 参照)。
    let dark = AppPalette(isDark: true, theme: theme)
    #expect(ColorContrast.ratio(dark.accentOnSoft, dark.accentSoft, dark.surface) >= 4.5)
  }

  @Test(arguments: ThemeColor.allCases, [false, true])
  func 購入を復元などカード地に直接載るアクセントの文字は4_5対1以上ある(theme: ThemeColor, isDark: Bool) {
    let palette = AppPalette(isDark: isDark, theme: theme)
    #expect(ColorContrast.ratio(palette.accentOnSoft, palette.surface, palette.surface) >= 4.5)
  }

  @Test func 外観がライトとダークならOSの配色に関わらずその配色で描く() {
    for system in [ColorScheme.light, .dark] {
      #expect(!AppAppearance.light.isDark(system: system))
      #expect(AppAppearance.dark.isDark(system: system))
    }
  }

  @Test func 外観がシステムと同じならOSの配色に従う() {
    #expect(!AppAppearance.system.isDark(system: .light))
    #expect(AppAppearance.system.isDark(system: .dark))
    #expect(AppAppearance.system.colorScheme == nil)
  }
}
