import SwiftUI

/// iOS のテーマカラー(アプリ全体のアクセント色)。ブルー以外は Pro で解放する。
///
/// 赤は削除・同期エラーの赤と、黄色は主ボタンの白文字と見分けがつかなくなるため入れていない。
/// rawValue は UserDefaults に保存する名前。並びは設定の色の一覧の並び。
nonisolated enum ThemeColor: String, CaseIterable, Sendable {
  case blue
  case indigo
  case purple
  case pink
  case orange
  case green
  case teal
  case graphite

  /// 未購入でも選べる色(アプリの元からの色)。
  static let free: ThemeColor = .blue

  /// 色の値。AppPalette のアクセント系のトークンはすべてここから作る。
  ///
  /// ブルーは 2.13.0 までのアプリの値そのまま。ほかの色は、淡い地(アクセント 12%)に載せる文字が 4.5:1 前後に
  /// なるよう `onSoft` を決めている(候補を比べた ~/Desktop/テーマカラー候補.html と同じ値)。
  var tones: Tones {
    switch self {
    case .blue:
      Tones(
        accent: 0x429FF0, accentDark: 0x429FF0, onSoftLight: 0x1B78C2, onSoftDark: 0x7EC2FF,
        gradientLight: (0x4DA4F2, 0x3F9CEF), gradientDark: (0x449DF0, 0x3795E9))
    case .indigo:
      Tones(
        accent: 0x5B6EE8, accentDark: 0x5B6EE8, onSoftLight: 0x495EE5, onSoftDark: 0x9CA7F1,
        gradientLight: (0x687AEA, 0x5B6EE8), gradientDark: (0x5B6EE8, 0x4E62E6))
    case .purple:
      Tones(
        accent: 0x9A62E0, accentDark: 0x9A62E0, onSoftLight: 0x8A48DB, onSoftDark: 0xC09EEC,
        gradientLight: (0xA26FE3, 0x9A62E0), gradientDark: (0x9A62E0, 0x9255DD))
    case .pink:
      Tones(
        accent: 0xE8578F, accentDark: 0xE8578F, onSoftLight: 0xD11D62, onSoftDark: 0xF091B6,
        gradientLight: (0xEA6498, 0xE8578F), gradientDark: (0xE8578F, 0xE64A86))
    case .orange:
      Tones(
        accent: 0xF07A30, accentDark: 0xF07A30, onSoftLight: 0xB74F0D, onSoftDark: 0xF4A06B,
        gradientLight: (0xF1833E, 0xF07A30), gradientDark: (0xF07A30, 0xEF7122))
    case .green:
      Tones(
        accent: 0x2FAF6A, accentDark: 0x2FAF6A, onSoftLight: 0x227D4C, onSoftDark: 0x3ECB7F,
        gradientLight: (0x32BB71, 0x2FAF6A), gradientDark: (0x2FAF6A, 0x2CA363))
    case .teal:
      Tones(
        accent: 0x1AA5A5, accentDark: 0x1AA5A5, onSoftLight: 0x137979, onSoftDark: 0x1FC6C6,
        gradientLight: (0x1CB2B2, 0x1AA5A5), gradientDark: (0x1AA5A5, 0x189898))
    case .graphite:
      // グラファイトだけダークでアクセントを明るくする。同じ灰色のままだと暗い面の上でタブやチェックが沈むため
      // (面 #242427 に対して 2.6:1 → 4.6:1)。
      Tones(
        accent: 0x5E6672, accentDark: 0x838C99, onSoftLight: 0x5E6672, onSoftDark: 0xA1A7B1,
        gradientLight: (0x656E7A, 0x5E6672), gradientDark: (0x5E6672, 0x575E6A))
    }
  }

  /// テーマカラー 1 色ぶんの値(どれも 0xRRGGBB)。
  struct Tones: Sendable {
    /// アクセント(ライト)。チェック・ラジオ・トグル・タブの選択中など。
    let accent: UInt32
    /// アクセント(ダーク)。
    let accentDark: UInt32
    /// 白地・淡いアクセントの地に置く文字色(ライト / ダーク)。押せる「文字」はこの色。
    let onSoftLight: UInt32
    let onSoftDark: UInt32
    /// 主ボタンの地(上 → 下)。
    let gradientLight: (UInt32, UInt32)
    let gradientDark: (UInt32, UInt32)
  }
}

extension ThemeColor {
  /// 色の名前(設定の表示用)。文言の参照は画面側の文脈で使うので、配色の値(nonisolated)とは分けて置く。
  var label: LocalizedStringResource {
    switch self {
    case .blue: .themeColorBlue
    case .indigo: .themeColorIndigo
    case .purple: .themeColorPurple
    case .pink: .themeColorPink
    case .orange: .themeColorOrange
    case .green: .themeColorGreen
    case .teal: .themeColorTeal
    case .graphite: .themeColorGraphite
    }
  }
}
